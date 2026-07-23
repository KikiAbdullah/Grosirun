<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Campaign extends Model
{
    use HasFactory;

    protected $fillable = [
        'uuid',
        'title',
        'description',
        'status',
        'initiator_id',
        'cluster_id',
        'offer_snapshot',
        'supplier_unit_price',
        'buyer_unit_price',
        'unit',
        'target_quantity',
        'current_quantity',
        'max_quantity',
        'deadline',
        'completed_at',
        'distribution_completed_at',
        'location_distribution',
    ];

    protected $casts = [
        'offer_snapshot' => 'array',
        'deadline' => 'datetime',
        'completed_at' => 'datetime',
        'distribution_completed_at' => 'datetime',
        'supplier_unit_price' => 'integer',
        'buyer_unit_price' => 'integer',
        'target_quantity' => 'integer',
        'current_quantity' => 'integer',
        'max_quantity' => 'integer',
    ];

    /**
     * Boot method to auto-generate UUID
     */
    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($campaign) {
            if (empty($campaign->uuid)) {
                $campaign->uuid = (string) Str::uuid();
            }
        });
    }

    /**
     * Get the route key for the model
     */
    public function getRouteKeyName()
    {
        return 'uuid';
    }

    /**
     * Get the initiator that created the campaign
     */
    public function initiator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'initiator_id');
    }

    /**
     * Get the cluster that the campaign belongs to
     */
    public function cluster(): BelongsTo
    {
        return $this->belongsTo(Cluster::class);
    }

    /**
     * Get variants for this campaign
     */
    public function variants(): HasMany
    {
        return $this->hasMany(CampaignVariant::class);
    }

    /**
     * Get orders for this campaign
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get purchase order for this campaign
     */
    public function purchaseOrder(): HasMany
    {
        return $this->hasMany(PurchaseOrder::class);
    }

    /**
     * Get paid orders count
     */
    public function getPaidOrdersCountAttribute(): int
    {
        return $this->orders()->where('payment_status', 'paid')->count();
    }

    /**
     * Get total revenue from paid orders
     */
    public function getTotalRevenueAttribute(): int
    {
        return $this->orders()
            ->where('payment_status', 'paid')
            ->sum('total_price');
    }

    /**
     * Calculate progress percentage
     */
    public function getProgressPercentageAttribute(): float
    {
        if ($this->target_quantity === 0) {
            return 0;
        }
        
        return min(100, ($this->current_quantity / $this->target_quantity) * 100);
    }

    /**
     * Check if target is reached
     */
    public function isTargetReached(): bool
    {
        return $this->current_quantity >= $this->target_quantity;
    }

    /**
     * Check if campaign is expired
     */
    public function isExpired(): bool
    {
        return $this->deadline->isPast();
    }

    /**
     * Check if campaign is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active' && !$this->isExpired();
    }

    /**
     * Scope to filter active campaigns
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
                    ->where('deadline', '>', now());
    }

    /**
     * Scope to filter by cluster
     */
    public function scopeInCluster($query, int $clusterId)
    {
        return $query->where('cluster_id', $clusterId);
    }

    /**
     * Scope to filter by initiator
     */
    public function scopeByInitiator($query, int $initiatorId)
    {
        return $query->where('initiator_id', $initiatorId);
    }

    /**
     * Increment current quantity (atomic operation)
     */
    public function incrementQuantity(int $quantity): bool
    {
        $result = $this->newQuery()
            ->where('id', $this->id)
            ->whereRaw('current_quantity + ? <= target_quantity', [$quantity])
            ->update(['current_quantity' => \DB::raw("current_quantity + {$quantity}")]);
        
        if ($result) {
            $this->current_quantity += $quantity;
            return true;
        }
        
        return false;
    }

    /**
     * Update status to target_reached if target met
     */
    public function checkAndUpdateStatus(): void
    {
        if ($this->isTargetReached() && $this->status === 'active') {
            $this->update(['status' => 'target_reached']);
        }
    }
}
