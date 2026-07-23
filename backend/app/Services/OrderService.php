<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Campaign;
use App\Models\CampaignVariant;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Exceptions\OversellException;
use App\Exceptions\AlreadyValidatedException;

class OrderService
{
    /**
     * Create order with ACID transaction and atomic operations
     * Prevents oversell and race conditions
     */
    public function createOrder(array $data, int $userId): Order
    {
        return DB::transaction(function () use ($data, $userId) {
            // Lock campaign and variant to prevent race conditions
            $campaign = Campaign::where('uuid', $data['campaign_uuid'])
                ->lockForUpdate()
                ->firstOrFail();

            $variant = CampaignVariant::where('id', $data['variant_id'])
                ->where('campaign_id', $campaign->id)
                ->lockForUpdate()
                ->firstOrFail();

            // Check campaign is active
            if ($campaign->status !== 'active') {
                throw new \Exception('Campaign is not active');
            }

            // Check deadline
            if ($campaign->deadline->isPast()) {
                throw new \Exception('Campaign deadline has passed');
            }

            // Check variant stock
            if (!$variant->hasStock($data['quantity'])) {
                throw new OversellException('Insufficient stock for this variant');
            }

            // Calculate totals
            $totalQuantity = $data['quantity'] * $variant->package_quantity;
            $totalPrice = $totalQuantity * $campaign->buyer_unit_price;

            // Check if user already has order for this campaign
            $existingOrder = Order::where('campaign_id', $campaign->id)
                ->where('user_id', $userId)
                ->whereIn('payment_status', ['pending', 'waiting_qris', 'paid'])
                ->first();

            if ($existingOrder) {
                throw new \Exception('User already has an active order for this campaign');
            }

            // Create order
            $order = Order::create([
                'uuid' => Str::uuid(),
                'campaign_id' => $campaign->id,
                'user_id' => $userId,
                'campaign_variant_id' => $variant->id,
                'cluster_id' => $campaign->cluster_id,
                'quantity' => $data['quantity'],
                'total_quantity' => $totalQuantity,
                'total_price' => $totalPrice,
                'payment_method' => $data['payment_method'],
                'payment_status' => $data['payment_method'] === 'cash' ? 'pending' : 'waiting_qris',
                'idempotency_key' => $data['idempotency_key'],
            ]);

            // Increment sold quantity atomically
            $variant->incrementSoldQuantity($data['quantity']);

            // Increment campaign current quantity
            $campaign->incrementQuantity($totalQuantity);

            // Check and update campaign status
            $campaign->checkAndUpdateStatus();

            // Log order creation
            $order->logs()->create([
                'type' => 'create_order',
                'notes' => "Order created: {$data['quantity']} x {$variant->name}",
                'after_data' => [
                    'quantity' => $data['quantity'],
                    'total_price' => $totalPrice,
                ],
            ]);

            return $order->load(['campaign', 'variant']);
        });
    }

    /**
     * Validate order payment (cash or QRIS)
     * Uses lockForUpdate to prevent race conditions
     */
    public function validateOrder(Order $order, ?string $notes = null): void
    {
        DB::transaction(function () use ($order, $notes) {
            // Lock order to prevent double validation
            $lockedOrder = Order::where('id', $order->id)
                ->lockForUpdate()
                ->firstOrFail();

            // Check if already validated
            if ($lockedOrder->payment_status === 'paid') {
                throw new AlreadyValidatedException('Order already validated');
            }

            // Update payment status
            $lockedOrder->markAsPaid($notes);

            // Log validation
            $lockedOrder->logs()->create([
                'type' => 'validate_payment',
                'initiator_id' => auth()->id(),
                'notes' => $notes,
                'after_data' => [
                    'payment_status' => 'paid',
                    'validated_at' => now()->toIso8601String(),
                ],
            ]);
        });
    }

    /**
     * Reject order payment
     */
    public function rejectOrder(Order $order, string $reason): void
    {
        DB::transaction(function () use ($order, $reason) {
            // Lock order
            $lockedOrder = Order::where('id', $order->id)
                ->lockForUpdate()
                ->firstOrFail();

            // Check if already processed
            if ($lockedOrder->payment_status === 'paid') {
                throw new \Exception('Cannot reject paid order');
            }

            // Reject order
            $lockedOrder->reject($reason);

            // Decrement variant sold quantity
            $lockedOrder->variant->decrementSoldQuantity($lockedOrder->quantity);

            // Decrement campaign current quantity
            $lockedOrder->campaign->decrementQuantity($lockedOrder->total_quantity);

            // Log rejection
            $lockedOrder->logs()->create([
                'type' => 'reject_payment',
                'initiator_id' => auth()->id(),
                'notes' => $reason,
                'after_data' => [
                    'payment_status' => 'rejected',
                    'rejection_reason' => $reason,
                ],
            ]);
        });
    }

    /**
     * Batch validate multiple orders
     */
    public function batchValidate(array $orderIds, ?string $notes = null): array
    {
        $results = [
            'success' => [],
            'failed' => [],
        ];

        foreach ($orderIds as $orderId) {
            try {
                $order = Order::where('uuid', $orderId)->firstOrFail();
                $this->validateOrder($order, $notes);
                $results['success'][] = $orderId;
            } catch (\Exception $e) {
                $results['failed'][] = [
                    'order_id' => $orderId,
                    'error' => $e->getMessage(),
                ];
            }
        }

        return $results;
    }

    /**
     * Upload payment proof
     */
    public function uploadProof(Order $order, string $filePath): void
    {
        DB::transaction(function () use ($order, $filePath) {
            // Lock order
            $lockedOrder = Order::where('id', $order->id)
                ->lockForUpdate()
                ->firstOrFail();

            // Check if already paid
            if ($lockedOrder->payment_status === 'paid') {
                throw new \Exception('Order already paid');
            }

            // Upload proof
            $lockedOrder->uploadProof($filePath);
        });
    }

    /**
     * Mark order as taken (distribution)
     */
    public function markAsTaken(Order $order): void
    {
        DB::transaction(function () use ($order) {
            // Lock order
            $lockedOrder = Order::where('id', $order->id)
                ->lockForUpdate()
                ->firstOrFail();

            // Check if paid
            if ($lockedOrder->payment_status !== 'paid') {
                throw new \Exception('Order must be paid before taking');
            }

            // Check if already taken
            if ($lockedOrder->is_taken) {
                throw new \Exception('Order already taken');
            }

            // Mark as taken
            $lockedOrder->markAsTaken();
        });
    }

    /**
     * Cancel order
     */
    public function cancelOrder(Order $order): void
    {
        DB::transaction(function () use ($order) {
            // Lock order
            $lockedOrder = Order::where('id', $order->id)
                ->lockForUpdate()
                ->firstOrFail();

            // Check if can be cancelled
            if ($lockedOrder->payment_status === 'paid') {
                throw new \Exception('Cannot cancel paid order');
            }

            // Decrement variant sold quantity
            $lockedOrder->variant->decrementSoldQuantity($lockedOrder->quantity);

            // Decrement campaign current quantity
            $lockedOrder->campaign->decrementQuantity($lockedOrder->total_quantity);

            // Delete order
            $lockedOrder->delete();

            // Log cancellation
            $order->logs()->create([
                'type' => 'cancel_order',
                'notes' => 'Order cancelled by user',
                'after_data' => ['status' => 'cancelled'],
            ]);
        });
    }

    /**
     * Get orders for user
     */
    public function getUserOrders(int $userId, ?int $clusterId = null)
    {
        $query = Order::where('user_id', $userId)
            ->with(['campaign', 'variant']);

        if ($clusterId) {
            $query->where('cluster_id', $clusterId);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }

    /**
     * Get orders for campaign validation
     */
    public function getCampaignOrdersForValidation(int $campaignId)
    {
        return Order::where('campaign_id', $campaignId)
            ->whereIn('payment_status', ['pending', 'waiting_qris'])
            ->with(['user', 'variant'])
            ->orderBy('created_at', 'asc')
            ->get();
    }

    /**
     * Get orders for distribution checklist
     */
    public function getCampaignOrdersForDistribution(int $campaignId)
    {
        return Order::where('campaign_id', $campaignId)
            ->where('payment_status', 'paid')
            ->with(['user', 'variant'])
            ->orderBy('is_taken', 'asc')
            ->orderBy('created_at', 'asc')
            ->get();
    }

    /**
     * Generate distribution recap
     */
    public function generateDistributionRecap(int $campaignId): array
    {
        $orders = $this->getCampaignOrdersForDistribution($campaignId);

        return [
            'total' => $orders->count(),
            'taken' => $orders->where('is_taken', true)->count(),
            'remaining' => $orders->where('is_taken', false)->count(),
            'orders' => $orders->map(function ($order) {
                return [
                    'uuid' => $order->uuid,
                    'user_name' => $order->user->name,
                    'variant_name' => $order->variant->name,
                    'quantity' => $order->quantity,
                    'is_taken' => $order->is_taken,
                    'taken_at' => $order->taken_at,
                    'taken_by' => $order->takenByInitiator?->name,
                ];
            })->toArray(),
        ];
    }
}
