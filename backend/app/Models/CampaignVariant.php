<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CampaignVariant extends Model
{
    use HasFactory;

    protected $fillable = [
        'campaign_id',
        'name',
        'package_quantity',
        'max_quantity',
        'sold_quantity',
    ];

    protected $casts = [
        'package_quantity' => 'integer',
        'max_quantity' => 'integer',
        'sold_quantity' => 'integer',
    ];

    /**
     * Get the campaign that owns this variant
     */
    public function campaign(): BelongsTo
    {
        return $this->belongsTo(Campaign::class);
    }

    /**
     * Get orders for this variant
     */
    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'campaign_variant_id');
    }

    /**
     * Get remaining quantity available
     */
    public function getRemainingQuantityAttribute(): int
    {
        return $this->max_quantity - $this->sold_quantity;
    }

    /**
     * Check if variant is sold out
     */
    public function isSoldOut(): bool
    {
        return $this->sold_quantity >= $this->max_quantity;
    }

    /**
     * Check if variant has available stock
     */
    public function hasStock(int $quantity = 1): bool
    {
        return ($this->sold_quantity + $quantity) <= $this->max_quantity;
    }

    /**
     * Increment sold quantity (atomic operation)
     */
    public function incrementSoldQuantity(int $quantity): bool
    {
        $result = \DB::update(
            'UPDATE campaign_variants SET sold_quantity = sold_quantity + ? WHERE id = ? AND sold_quantity + ? <= max_quantity',
            [$quantity, $this->id, $quantity]
        );
        
        if ($result) {
            $this->sold_quantity += $quantity;
            return true;
        }
        
        return false;
    }

    /**
     * Decrement sold quantity (for cancellations)
     */
    public function decrementSoldQuantity(int $quantity): bool
    {
        $result = \DB::update(
            'UPDATE campaign_variants SET sold_quantity = sold_quantity - ? WHERE id = ? AND sold_quantity - ? >= 0',
            [$quantity, $this->id, $quantity]
        );
        
        if ($result) {
            $this->sold_quantity -= $quantity;
            return true;
        }
        
        return false;
    }

    /**
     * Scope to filter available variants
     */
    public function scopeAvailable($query)
    {
        return $query->whereRaw('sold_quantity < max_quantity');
    }
}
