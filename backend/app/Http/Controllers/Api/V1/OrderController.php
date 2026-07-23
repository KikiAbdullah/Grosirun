<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use App\Services\ImageService;
use App\Models\Order;
use App\Models\Campaign;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    protected OrderService $orderService;
    protected ImageService $imageService;

    public function __construct(OrderService $orderService, ImageService $imageService)
    {
        $this->orderService = $orderService;
        $this->imageService = $imageService;
    }

    /**
     * Create order
     * POST /api/v1/orders
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'campaign_uuid' => 'required|exists:campaigns,uuid',
            'variant_id' => 'required|exists:campaign_variants,id',
            'quantity' => 'required|integer|min:1',
            'payment_method' => 'required|in:cash,qris',
            'idempotency_key' => 'required|string|unique:orders,idempotency_key',
        ]);

        try {
            $order = $this->orderService->createOrder($validated, $request->user()->id);

            return response()->json([
                'message' => 'Order created successfully',
                'order' => $order,
            ], 201);
        } catch (\App\Exceptions\OversellException $e) {
            return response()->json([
                'message' => 'Insufficient stock',
                'error' => $e->getMessage(),
            ], 409);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to create order',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Get user orders
     * GET /api/v1/orders
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $clusterId = $request->query('cluster_id');

        $orders = $this->orderService->getUserOrders($user->id, $clusterId);

        return response()->json([
            'orders' => $orders,
        ]);
    }

    /**
     * Get order detail
     * GET /api/v1/orders/{uuid}
     */
    public function show(string $uuid)
    {
        $user = $request()->user();
        $order = Order::where('uuid', $uuid)
            ->with(['campaign', 'variant', 'user'])
            ->firstOrFail();

        // Check authorization
        if ($order->user_id !== $user->id && 
            $order->campaign->initiator_id !== $user->id &&
            $user->active_role !== 'admin') {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        return response()->json([
            'order' => $order,
        ]);
    }

    /**
     * Upload payment proof
     * POST /api/v1/orders/{uuid}/proof
     */
    public function uploadProof(Request $request, string $uuid)
    {
        $request->validate([
            'proof' => 'required|file|mimes:jpeg,jpg,png|max:2048',
        ]);

        $user = $request->user();
        $order = Order::where('uuid', $uuid)->firstOrFail();

        // Check authorization
        if ($order->user_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        // Check if already paid
        if ($order->payment_status === 'paid') {
            return response()->json([
                'message' => 'Order already paid',
            ], 422);
        }

        try {
            // Upload proof image
            $proofPath = $this->imageService->uploadProof($request->file('proof'));

            // Update order
            $this->orderService->uploadProof($order, $proofPath);

            return response()->json([
                'message' => 'Proof uploaded successfully',
                'order' => $order->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to upload proof',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Get proof URL
     * GET /api/v1/orders/{uuid}/proof-url
     */
    public function proofUrl(Request $request, string $uuid)
    {
        $user = $request->user();
        $order = Order::where('uuid', $uuid)->firstOrFail();

        // Check authorization
        if ($order->user_id !== $user->id && 
            $order->campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        if (!$order->proof_path) {
            return response()->json([
                'message' => 'No proof uploaded',
            ], 404);
        }

        $proofUrl = $this->imageService->getTemporaryUrl($order->proof_path);

        return response()->json([
            'proof_url' => $proofUrl,
            'expires_at' => now()->addHour()->toIso8601String(),
        ]);
    }

    /**
     * Validate order (initiator only)
     * POST /api/v1/orders/{uuid}/validate
     */
    public function validate(Request $request, string $uuid)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Only initiators can validate orders',
            ], 403);
        }

        $order = Order::where('uuid', $uuid)->firstOrFail();

        // Check if initiator owns this campaign
        if ($order->campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'notes' => 'nullable|string',
        ]);

        try {
            $this->orderService->validateOrder($order, $validated['notes'] ?? null);

            return response()->json([
                'message' => 'Order validated successfully',
                'order' => $order->fresh(),
            ]);
        } catch (\App\Exceptions\AlreadyValidatedException $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 409);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to validate order',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Reject order (initiator only)
     * POST /api/v1/orders/{uuid}/reject
     */
    public function reject(Request $request, string $uuid)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Only initiators can reject orders',
            ], 403);
        }

        $order = Order::where('uuid', $uuid)->firstOrFail();

        // Check if initiator owns this campaign
        if ($order->campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'reason' => 'required|string',
        ]);

        try {
            $this->orderService->rejectOrder($order, $validated['reason']);

            return response()->json([
                'message' => 'Order rejected',
                'order' => $order->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to reject order',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Batch validate orders
     * POST /api/v1/orders/batch-validate
     */
    public function batchValidate(Request $request)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Only initiators can validate orders',
            ], 403);
        }

        $validated = $request->validate([
            'order_uuids' => 'required|array|min:1|max:100',
            'order_uuids.*' => 'string|exists:orders,uuid',
            'notes' => 'nullable|string',
        ]);

        $results = $this->orderService->batchValidate($validated['order_uuids'], $validated['notes'] ?? null);

        return response()->json([
            'message' => 'Batch validation completed',
            'results' => $results,
        ], 207);
    }

    /**
     * Get orders for validation (initiator only)
     * GET /api/v1/campaigns/{uuid}/orders/pending
     */
    public function pendingValidation(Request $request, string $campaignUuid)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $campaign = Campaign::where('uuid', $campaignUuid)->firstOrFail();

        if ($campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $orders = $this->orderService->getCampaignOrdersForValidation($campaign->id);

        return response()->json([
            'orders' => $orders,
        ]);
    }

    /**
     * Get orders for distribution
     * GET /api/v1/campaigns/{uuid}/orders/distribution
     */
    public function distribution(Request $request, string $campaignUuid)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $campaign = Campaign::where('uuid', $campaignUuid)->firstOrFail();

        if ($campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $orders = $this->orderService->getCampaignOrdersForDistribution($campaign->id);

        return response()->json([
            'orders' => $orders,
        ]);
    }

    /**
     * Mark order as taken (distribution)
     * POST /api/v1/orders/{uuid}/take
     */
    public function markAsTaken(Request $request, string $uuid)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Only initiators can mark orders as taken',
            ], 403);
        }

        $order = Order::where('uuid', $uuid)->firstOrFail();

        // Check if initiator owns this campaign
        if ($order->campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        try {
            $this->orderService->markAsTaken($order);

            return response()->json([
                'message' => 'Order marked as taken',
                'order' => $order->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to mark order as taken',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Cancel order
     * DELETE /api/v1/orders/{uuid}
     */
    public function destroy(Request $request, string $uuid)
    {
        $user = $request->user();
        $order = Order::where('uuid', $uuid)->firstOrFail();

        // Check authorization
        if ($order->user_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        // Check if can be cancelled
        if ($order->payment_status === 'paid') {
            return response()->json([
                'message' => 'Cannot cancel paid order',
            ], 422);
        }

        try {
            $this->orderService->cancelOrder($order);

            return response()->json([
                'message' => 'Order cancelled',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to cancel order',
                'error' => $e->getMessage(),
            ], 422);
        }
    }
}
