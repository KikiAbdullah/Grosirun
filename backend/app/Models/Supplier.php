<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Supplier extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'address',
        'service_areas',
        'contact_business',
        'verification_status',
        'verification_notes',
    ];

    protected $casts = [
        'service_areas' => 'array',
    ];

    /**
     * Get the members of this supplier
     */
    public function members(): HasMany
    {
        return $this->hasMany(SupplierMember::class);
    }

    /**
     * Get the products offered by this supplier
     */
    public function products(): HasMany
    {
        return $this->hasMany(SupplierProduct::class);
    }

    /**
     * Get the offers from this supplier
     */
    public function offers(): HasMany
    {
        return $this->hasMany(SupplierOffer::class);
    }

    /**
     * Get the purchase orders for this supplier
     */
    public function purchaseOrders(): HasMany
    {
        return $this->hasMany(PurchaseOrder::class);
    }

    /**
     * Check if supplier is verified
     */
    public function isVerified(): bool
    {
        return $this->verification_status === 'approved';
    }

    /**
     * Check if supplier is pending verification
     */
    public function isPending(): bool
    {
        return $this->verification_status === 'pending';
    }

    /**
     * Check if supplier is rejected
     */
    public function isRejected(): bool
    {
        return $this->verification_status === 'rejected';
    }

    /**
     * Scope to filter verified suppliers
     */
    public function scopeVerified($query)
    {
        return $query->where('verification_status', 'approved');
    }

    /**
     * Scope to filter pending suppliers
     */
    public function scopePending($query)
    {
        return $query->where('verification_status', 'pending');
    }
}
