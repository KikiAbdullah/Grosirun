<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class PurchaseOrder extends Model
{
    use HasFactory;

    protected $fillable = [
        'uuid',
        'campaign_id',
        'supplier_id',
        'initiator_id',
        'total_quantity',
        'unit_price',
        'total_amount',
        'status',
        'payment_proof_path',
        'payment_proof_url',
        'payment_status',
        'rejected_reason',
        'accepted_at',
        'rejected_at',
    ];

    protected $casts = [
        'total_quantity' => 'integer',
        'unit_price' => 'integer',
        'total_amount' => 'integer',
        'accepted_at' => 'datetime',
        'rejected_at' => 'datetime',
    ];

    /**
     * Boot method to auto-generate UUID
     */
    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($po) {
            if (empty($po->uuid)) {
                $po->uuid = (string) Str::uuid();
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
     * Get the campaign that created this PO
     */
    public function campaign(): BelongsTo
    {
        return $this->belongsTo(Campaign::class);
    }

    /**
     * Get the supplier for this PO
     */
    public function supplier(): BelongsTo
    {
        return $this->belongsTo(Supplier::class);
    }

    /**
     * Get the initiator who created this PO
     */
    public function initiator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'initiator_id');
    }

    /**
     * Get documents for this PO
     */
    public function documents(): HasMany
    {
        return $this->hasMany(PurchaseOrderDocument::class);
    }

    /**
     * Check if PO is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if PO is accepted
     */
    public function isAccepted(): bool
    {
        return $this->status === 'accepted';
    }

    /**
     * Check if PO is rejected
     */
    public function isRejected(): bool
    {
        return $this->status === 'rejected';
    }

    /**
     * Check if PO is completed
     */
    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    /**
     * Accept the PO
     */
    public function accept(): void
    {
        $this->update([
            'status' => 'accepted',
            'accepted_at' => now(),
        ]);
    }

    /**
     * Reject the PO
     */
    public function reject(string $reason): void
    {
        $this->update([
            'status' => 'rejected',
            'rejected_reason' => $reason,
            'rejected_at' => now(),
        ]);
    }

    /**
     * Complete the PO
     */
    public function complete(): void
    {
        $this->update([
            'status' => 'completed',
        ]);
    }

    /**
     * Scope to filter pending POs
     */
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    /**
     * Scope to filter accepted POs
     */
    public function scopeAccepted($query)
    {
        return $query->where('status', 'accepted');
    }

    /**
     * Scope to filter by supplier
     */
    public function scopeForSupplier($query, int $supplierId)
    {
        return $query->where('supplier_id', $supplierId);
    }
}
