<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class SupplierOffer extends Model
{
    use HasFactory;

    protected $fillable = [
        'uuid',
        'supplier_id',
        'product_id',
        'title',
        'description',
        'minimum_quantity',
        'capacity',
        'reserved_capacity',
        'tier_prices',
        'service_areas',
        'delivery_cost',
        'valid_until',
        'status',
    ];

    protected $casts = [
        'tier_prices' => 'array',
        'service_areas' => 'array',
        'valid_until' => 'datetime',
        'minimum_quantity' => 'integer',
        'capacity' => 'integer',
        'reserved_capacity' => 'integer',
        'delivery_cost' => 'integer',
    ];

    /**
     * Boot method to auto-generate UUID
     */
    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($offer) {
            if (empty($offer->uuid)) {
                $offer->uuid = (string) Str::uuid();
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
     * Get the supplier that owns this offer
     */
    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class);
    }

    /**
     * Get the product for this offer
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(SupplierProduct::class, 'product_id');
    }

    /**
     * Get campaigns created from this offer
     */
    public function campaigns(): HasMany
    {
        return $this->hasMany(Campaign::class, 'offer_id');
    }

    /**
     * Get active campaigns from this offer
     */
    public function activeCampaigns(): HasMany
    {
        return $this->hasMany(Campaign::class, 'offer_id')
            ->whereIn('status', ['active', 'target_reached']);
    }

    /**
     * Get current price based on quantity
     */
    public function getCurrentPrice(int $quantity): int
    {
        $tiers = collect($this->tier_prices);
        
        $matchingTier = $tiers->first(function ($tier) use ($quantity) {
            $min = $tier['min'] ?? 0;
            $max = $tier['max'] ?? PHP_INT_MAX;
            return $quantity >= $min && $quantity <= $max;
        });

        return $matchingTier ? $matchingTier['price'] : $tiers->first()['price'];
    }

    /**
     * Get available capacity
     */
    public function getAvailableCapacityAttribute(): int
    {
        return $this->capacity - $this->reserved_capacity;
    }

    /**
     * Check if offer is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active' && $this->valid_until->isFuture();
    }

    /**
     * Check if offer is expired
     */
    public function isExpired(): bool
    {
        return $this->valid_until->isPast();
    }

    /**
     * Check if offer has sufficient capacity
     */
    public function hasCapacity(int $quantity): bool
    {
        return $this->available_capacity >= $quantity;
    }

    /**
     * Reserve capacity
     */
    public function reserveCapacity(int $quantity): bool
    {
        if (!$this->hasCapacity($quantity)) {
            return false;
        }

        $this->increment('reserved_capacity', $quantity);
        return true;
    }

    /**
     * Release reserved capacity
     */
    public function releaseCapacity(int $quantity): void
    {
        $this->decrement('reserved_capacity', $quantity);
    }

    /**
     * Scope to filter active offers
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
                    ->where('valid_until', '>', now());
    }

    /**
     * Scope to filter by supplier
     */
    public function scopeForSupplier($query, int $supplierId)
    {
        return $query->where('supplier_id', $supplierId);
    }

    /**
     * Scope to filter by service area
     */
    public function scopeForArea($query, string $clusterCode)
    {
        return $query->whereJsonContains('service_areas', $clusterCode);
    }

    /**
     * Scope to filter offers with sufficient capacity
     */
    public function scopeWithCapacity($query, int $quantity)
    {
        return $query->whereRaw('(capacity - reserved_capacity) >= ?', [$quantity]);
    }
}
