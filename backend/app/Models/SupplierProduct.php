<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SupplierProduct extends Model
{
    use HasFactory;

    protected $fillable = [
        'supplier_id',
        'name',
        'base_unit',
        'description',
        'image_path',
    ];

    /**
     * Get the supplier that owns this product
     */
    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class);
    }

    /**
     * Get the offers for this product
     */
    public function offers(): HasMany
    {
        return $this->hasMany(SupplierOffer::class, 'product_id');
    }

    /**
     * Get active offers for this product
     */
    public function activeOffers(): HasMany
    {
        return $this->hasMany(SupplierOffer::class, 'product_id')
            ->where('status', 'active')
            ->where('valid_until', '>', now());
    }

    /**
     * Scope to filter by supplier
     */
    public function scopeForSupplier($query, int $supplierId)
    {
        return $query->where('supplier_id', $supplierId);
    }
}
