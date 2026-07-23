<?php

namespace App\Services;

use App\Models\Campaign;
use App\Models\CampaignVariant;
use App\Models\SupplierOffer;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class CampaignService
{
    /**
     * Create campaign from supplier offer
     * Uses atomic transaction to prevent race conditions
     */
    public function createCampaign(array $data, int $initiatorId): Campaign
    {
        return DB::transaction(function () use ($data, $initiatorId) {
            // Lock the offer to prevent concurrent campaign creation
            $offer = SupplierOffer::where('uuid', $data['offer_uuid'])
                ->lockForUpdate()
                ->firstOrFail();

            // Validate offer is active and valid
            if (!$offer->isActive()) {
                throw new \Exception('Offer is not active or has expired');
            }

            // Check capacity
            $existingCampaigns = Campaign::where('offer_id', $offer->id)
                ->whereIn('status', ['active', 'target_reached'])
                ->sum('target_quantity');

            if ($existingCampaigns + $data['target_quantity'] > $offer->capacity) {
                throw new \Exception('Insufficient capacity in offer');
            }

            // Reserve capacity atomically
            $offer->increment('reserved_capacity', $data['target_quantity']);

            // Create campaign snapshot
            $snapshot = [
                'supplier_id' => $offer->supplier_id,
                'product_name' => $offer->product->name,
                'unit' => $offer->product->base_unit,
                'supplier_unit_price' => $offer->getCurrentPrice($data['target_quantity']),
                'tier' => $offer->tier_prices,
                'capacity' => $offer->capacity,
                'delivery_cost' => $offer->delivery_cost,
                'validity' => $offer->valid_until->toIso8601String(),
            ];

            // Create campaign
            $campaign = Campaign::create([
                'uuid' => Str::uuid(),
                'title' => $data['title'],
                'description' => $data['description'] ?? null,
                'status' => 'active',
                'initiator_id' => $initiatorId,
                'cluster_id' => $data['cluster_id'],
                'offer_id' => $offer->id,
                'offer_snapshot' => $snapshot,
                'supplier_unit_price' => $snapshot['supplier_unit_price'],
                'buyer_unit_price' => $data['buyer_unit_price'],
                'unit' => $offer->product->base_unit,
                'target_quantity' => $data['target_quantity'],
                'current_quantity' => 0,
                'max_quantity' => $offer->capacity,
                'deadline' => $data['deadline'],
                'location_distribution' => $data['location_distribution'],
            ]);

            // Create variants
            foreach ($data['variants'] as $variantData) {
                CampaignVariant::create([
                    'campaign_id' => $campaign->id,
                    'name' => $variantData['name'],
                    'package_quantity' => $variantData['package_quantity'],
                    'max_quantity' => $variantData['max_quantity'],
                    'sold_quantity' => 0,
                ]);
            }

            return $campaign->load('variants');
        });
    }

    /**
     * Get active campaigns for cluster
     */
    public function getActiveCampaigns(int $clusterId)
    {
        return Campaign::where('cluster_id', $clusterId)
            ->where('status', 'active')
            ->where('deadline', '>', now())
            ->with(['initiator', 'variants'])
            ->orderBy('deadline', 'asc')
            ->get();
    }

    /**
     * Get campaign detail
     */
    public function getCampaignDetail(string $uuid): Campaign
    {
        return Campaign::where('uuid', $uuid)
            ->with(['initiator', 'cluster', 'variants', 'orders.user'])
            ->firstOrFail();
    }

    /**
     * Update campaign status based on current quantity
     */
    public function checkAndUpdateStatus(Campaign $campaign): void
    {
        if ($campaign->current_quantity >= $campaign->target_quantity) {
            $campaign->update(['status' => 'target_reached']);
        } elseif ($campaign->deadline->isPast()) {
            $campaign->update(['status' => 'expired']);
        }
    }

    /**
     * Extend campaign deadline
     */
    public function extendDeadline(Campaign $campaign, int $hours = 24): Campaign
    {
        $campaign->update([
            'deadline' => $campaign->deadline->addHours($hours),
        ]);

        return $campaign;
    }

    /**
     * Cancel campaign
     */
    public function cancelCampaign(Campaign $campaign, string $reason): void
    {
        DB::transaction(function () use ($campaign, $reason) {
            // Release reserved capacity
            $campaign->offer->decrement('reserved_capacity', $campaign->target_quantity);

            // Update status
            $campaign->update([
                'status' => 'cancelled',
                'completed_at' => now(),
            ]);

            // Log cancellation
            $campaign->logs()->create([
                'type' => 'cancel_campaign',
                'initiator_id' => auth()->id(),
                'notes' => $reason,
                'after_data' => ['status' => 'cancelled'],
            ]);
        });
    }

    /**
     * Get campaign statistics
     */
    public function getCampaignStats(Campaign $campaign): array
    {
        return [
            'total_orders' => $campaign->orders()->count(),
            'paid_orders' => $campaign->orders()->where('payment_status', 'paid')->count(),
            'pending_orders' => $campaign->orders()->whereIn('payment_status', ['pending', 'waiting_qris'])->count(),
            'total_quantity' => $campaign->current_quantity,
            'target_quantity' => $campaign->target_quantity,
            'progress_percentage' => $campaign->progress_percentage,
            'total_revenue' => $campaign->orders()->where('payment_status', 'paid')->sum('total_price'),
            'taken_orders' => $campaign->orders()->where('is_taken', true)->count(),
            'remaining_orders' => $campaign->orders()->where('is_taken', false)->where('payment_status', 'paid')->count(),
        ];
    }

    /**
     * Complete distribution
     */
    public function completeDistribution(Campaign $campaign): void
    {
        // Check all paid orders are taken
        $remainingOrders = $campaign->orders()
            ->where('payment_status', 'paid')
            ->where('is_taken', false)
            ->count();

        if ($remainingOrders > 0) {
            throw new \Exception("{$remainingOrders} orders still not taken");
        }

        $campaign->update([
            'status' => 'completed',
            'distribution_completed_at' => now(),
        ]);

        // Log completion
        $campaign->logs()->create([
            'type' => 'complete_distribution',
            'initiator_id' => auth()->id(),
            'notes' => 'Distribution completed',
            'after_data' => ['status' => 'completed'],
        ]);
    }

    /**
     * Check and expire campaigns (scheduled job)
     */
    public function expireCampaigns(): int
    {
        $expired = Campaign::where('status', 'active')
            ->where('deadline', '<', now())
            ->update(['status' => 'expired']);

        return $expired;
    }

    /**
     * Generate recap PDF
     */
    public function generateRecapPdf(Campaign $campaign): string
    {
        $pdf = \PDF::loadView('pdf.campaign-recap', [
            'campaign' => $campaign->load(['initiator', 'cluster', 'variants', 'orders.user']),
            'stats' => $this->getCampaignStats($campaign),
        ]);

        $filename = "recaps/{$campaign->uuid}-" . now()->format('Y-m-d') . ".pdf";
        \Storage::disk('s3')->put($filename, $pdf->output());

        return $filename;
    }
}
