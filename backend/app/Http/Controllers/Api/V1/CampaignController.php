<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\CampaignService;
use App\Models\Campaign;
use Illuminate\Http\Request;

class CampaignController extends Controller
{
    protected CampaignService $campaignService;

    public function __construct(CampaignService $campaignService)
    {
        $this->campaignService = $campaignService;
    }

    /**
     * List active campaigns for user's cluster
     * GET /api/v1/campaigns
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        if (!$user->cluster_id) {
            return response()->json([
                'message' => 'User must be assigned to a cluster',
            ], 400);
        }

        $campaigns = $this->campaignService->getActiveCampaigns($user->cluster_id);

        return response()->json([
            'campaigns' => $campaigns,
        ]);
    }

    /**
     * Get campaign detail
     * GET /api/v1/campaigns/{uuid}
     */
    public function show(string $uuid)
    {
        $campaign = $this->campaignService->getCampaignDetail($uuid);

        return response()->json([
            'campaign' => $campaign,
            'stats' => $this->campaignService->getCampaignStats($campaign),
        ]);
    }

    /**
     * Create new campaign (initiator only)
     * POST /api/v1/campaigns
     */
    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->active_role !== 'initiator') {
            return response()->json([
                'message' => 'Only initiators can create campaigns',
            ], 403);
        }

        $validated = $request->validate([
            'offer_uuid' => 'required|exists:supplier_offers,uuid',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'cluster_id' => 'required|exists:clusters,id',
            'buyer_unit_price' => 'required|integer|min:0',
            'target_quantity' => 'required|integer|min:1',
            'deadline' => 'required|date|after:now',
            'location_distribution' => 'required|string',
            'variants' => 'required|array|min:1',
            'variants.*.name' => 'required|string',
            'variants.*.package_quantity' => 'required|integer|min:1',
            'variants.*.max_quantity' => 'required|integer|min:1',
        ]);

        try {
            $campaign = $this->campaignService->createCampaign($validated, $user->id);

            return response()->json([
                'message' => 'Campaign created successfully',
                'campaign' => $campaign,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to create campaign',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Extend campaign deadline
     * POST /api/v1/campaigns/{uuid}/extend
     */
    public function extend(Request $request, string $uuid)
    {
        $user = $request->user();
        $campaign = Campaign::where('uuid', $uuid)->firstOrFail();

        if ($campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'hours' => 'integer|min:1|max:48',
        ]);

        $campaign = $this->campaignService->extendDeadline($campaign, $validated['hours'] ?? 24);

        return response()->json([
            'message' => 'Deadline extended',
            'campaign' => $campaign,
        ]);
    }

    /**
     * Cancel campaign
     * POST /api/v1/campaigns/{uuid}/cancel
     */
    public function cancel(Request $request, string $uuid)
    {
        $user = $request->user();
        $campaign = Campaign::where('uuid', $uuid)->firstOrFail();

        if ($campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'reason' => 'required|string',
        ]);

        $this->campaignService->cancelCampaign($campaign, $validated['reason']);

        return response()->json([
            'message' => 'Campaign cancelled',
        ]);
    }

    /**
     * Generate recap PDF
     * GET /api/v1/campaigns/{uuid}/recap
     */
    public function recap(Request $request, string $uuid)
    {
        $user = $request->user();
        $campaign = Campaign::where('uuid', $uuid)->firstOrFail();

        if ($campaign->initiator_id !== $user->id && $user->active_role !== 'admin') {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        $pdfPath = $this->campaignService->generateRecapPdf($campaign);
        $pdfUrl = \Storage::disk('s3')->temporaryUrl($pdfPath, now()->addHour());

        return response()->json([
            'recap_url' => $pdfUrl,
            'expires_at' => now()->addHour()->toIso8601String(),
        ]);
    }

    /**
     * Complete distribution
     * POST /api/v1/campaigns/{uuid}/complete-distribution
     */
    public function completeDistribution(Request $request, string $uuid)
    {
        $user = $request->user();
        $campaign = Campaign::where('uuid', $uuid)->firstOrFail();

        if ($campaign->initiator_id !== $user->id) {
            return response()->json([
                'message' => 'Unauthorized',
            ], 403);
        }

        try {
            $this->campaignService->completeDistribution($campaign);

            return response()->json([
                'message' => 'Distribution completed',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to complete distribution',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Get campaign statistics
     * GET /api/v1/campaigns/{uuid}/stats
     */
    public function stats(string $uuid)
    {
        $campaign = Campaign::where('uuid', $uuid)->firstOrFail();
        $stats = $this->campaignService->getCampaignStats($campaign);

        return response()->json([
            'stats' => $stats,
        ]);
    }
}
