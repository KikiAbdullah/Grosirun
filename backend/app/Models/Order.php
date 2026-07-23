<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'uuid',
        'campaign_id',
        'user_id',
        'campaign_variant_id',
        'cluster_id',
        'quantity',
        'total_quantity',
        'total_price',
        'payment_method',
        'payment_status',
        'proof_path',
        'proof_url',
        'proof_uploaded_at',
        'is_taken',
        'taken_at',
        'taken_by_initiator_id',
        'validation_notes',
        'rejection_reason',
        'idempotency_key',
    ];

    protected $casts = [
        'total_quantity' => 'integer',
        'total_price' => 'integer',
        'quantity' => 'integer',
        'is_taken' => 'boolean',
        'proof_uploaded_at' => 'datetime',
        'taken_at' => 'datetime',
    ];

    /**
     * Boot method to auto-generate UUID
     */
    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($order) {
            if (empty($order->uuid)) {
                $order->uuid = (string) Str::uuid();
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
     * Get the campaign that this order belongs to
     */
    public function campaign(): BelongsTo
    {
        return $this->belongsTo(Campaign::class);
    }

    /**
     * Get the user who created this order
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the variant that was ordered
     */
    public function variant(): BelongsTo
    {
        return $this->belongsTo(CampaignVariant::class, 'campaign_variant_id');
    }

    /**
     * Get the cluster that this order belongs to
     */
    public function cluster(): BelongsTo
    {
        return $this->belongsTo(Cluster::class);
    }

    /**
     * Get the initiator who took this order (for distribution)
     */
    public function takenByInitiator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'taken_by_initiator_id');
    }

    /**
     * Get transaction logs for this order
     */
    public function logs(): HasMany
    {
        return $this->morphMany(TransactionLog::class, 'loggable');
    }

    /**
     * Check if order is pending payment
     */
    public function isPending(): bool
    {
        return in_array($this->payment_status, ['pending', 'waiting_qris']);
    }

    /**
     * Check if order is paid
     */
    public function isPaid(): bool
    {
        return $this->payment_status === 'paid';
    }

    /**
     * Check if order is rejected
     */
    public function isRejected(): bool
    {
        return $this->payment_status === 'rejected';
    }

    /**
     * Check if order is taken (for distribution)
     */
    public function isTaken(): bool
    {
        return $this->is_taken;
    }

    /**
     * Check if proof is uploaded
     */
    public function hasProof(): bool
    {
        return !empty($this->proof_path);
    }

    /**
     * Get temporary URL for proof (1 hour expiry)
     */
    public function getProofUrl(): ?string
    {
        if (!$this->hasProof()) {
            return null;
        }

        return Storage::disk('s3')->temporaryUrl(
            $this->proof_path,
            now()->addHour()
        );
    }

    /**
     * Mark order as paid
     */
    public function markAsPaid(?string $notes = null): void
    {
        $this->update([
            'payment_status' => 'paid',
            'validation_notes' => $notes,
        ]);

        // Log transaction
        $this->logs()->create([
            'type' => 'validation',
            'initiator_id' => auth()->id(),
            'notes' => $notes,
            'after_data' => ['payment_status' => 'paid'],
        ]);
    }

    /**
     * Reject order
     */
    public function reject(string $reason): void
    {
        $this->update([
            'payment_status' => 'rejected',
            'rejection_reason' => $reason,
        ]);

        // Log transaction
        $this->logs()->create([
            'type' => 'rejection',
            'initiator_id' => auth()->id(),
            'notes' => $reason,
            'after_data' => [
                'payment_status' => 'rejected',
                'rejection_reason' => $reason,
            ],
        ]);
    }

    /**
     * Mark order as taken (for distribution)
     */
    public function markAsTaken(?int $initiatorId = null): void
    {
        $this->update([
            'is_taken' => true,
            'taken_at' => now(),
            'taken_by_initiator_id' => $initiatorId ?? auth()->id(),
        ]);

        // Log transaction
        $this->logs()->create([
            'type' => 'distribution',
            'initiator_id' => $initiatorId ?? auth()->id(),
            'notes' => 'Order taken by buyer',
            'after_data' => ['is_taken' => true],
        ]);
    }

    /**
     * Upload proof
     */
    public function uploadProof(string $path): void
    {
        $this->update([
            'proof_path' => $path,
            'proof_uploaded_at' => now(),
            'payment_status' => 'waiting_qris',
        ]);

        // Log transaction
        $this->logs()->create([
            'type' => 'proof_upload',
            'notes' => 'Payment proof uploaded',
            'after_data' => ['proof_path' => $path],
        ]);
    }

    /**
     * Scope to filter pending orders
     */
    public function scopePending($query)
    {
        return $query->whereIn('payment_status', ['pending', 'waiting_qris']);
    }

    /**
     * Scope to filter paid orders
     */
    public function scopePaid($query)
    {
        return $query->where('payment_status', 'paid');
    }

    /**
     * Scope to filter by campaign
     */
    public function scopeForCampaign($query, int $campaignId)
    {
        return $query->where('campaign_id', $campaignId);
    }

    /**
     * Scope to filter by user
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope to filter by cluster
     */
    public function scopeInCluster($query, int $clusterId)
    {
        return $query->where('cluster_id', $clusterId);
    }

    /**
     * Scope to filter not taken orders
     */
    public function scopeNotTaken($query)
    {
        return $query->where('is_taken', false);
    }

    /**
     * Scope to filter taken orders
     */
    public function scopeTaken($query)
    {
        return $query->where('is_taken', true);
    }
}
