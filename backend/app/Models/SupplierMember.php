<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SupplierMember extends Model
{
    use HasFactory;

    protected $fillable = [
        'supplier_id',
        'user_id',
        'role',
    ];

    /**
     * Get the supplier that this member belongs to
     */
    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class);
    }

    /**
     * Get the user that is a member
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if member is owner
     */
    public function isOwner(): bool
    {
        return $this->role === 'owner';
    }

    /**
     * Check if member is sales
     */
    public function isSales(): bool
    {
        return $this->role === 'sales';
    }

    /**
     * Check if member is warehouse
     */
    public function isWarehouse(): bool
    {
        return $this->role === 'warehouse';
    }

    /**
     * Scope to filter owners
     */
    public function scopeOwners($query)
    {
        return $query->where('role', 'owner');
    }

    /**
     * Scope to filter sales
     */
    public function scopeSales($query)
    {
        return $query->where('role', 'sales');
    }

    /**
     * Scope to filter warehouse
     */
    public function scopeWarehouse($query)
    {
        return $query->where('role', 'warehouse');
    }
}
