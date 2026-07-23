<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class TransactionLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'action',
        'user_id',
        'loggable_type',
        'loggable_id',
        'before',
        'after',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'before' => 'array',
        'after' => 'array',
    ];

    /**
     * Get the user that performed the action
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the loggable model (polymorphic)
     */
    public function loggable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Scope to filter by user
     */
    public function scopeByUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope to filter by action
     */
    public function scopeOfAction($query, string $action)
    {
        return $query->where('action', $action);
    }

    /**
     * Scope to filter by loggable type
     */
    public function scopeForType($query, string $type)
    {
        return $query->where('loggable_type', $type);
    }

    /**
     * Scope to order by latest
     */
    public function scopeLatest($query)
    {
        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Get description of the action
     */
    public function getDescriptionAttribute(): string
    {
        return match($this->action) {
            'order_created' => 'Pesanan dibuat',
            'proof_uploaded' => 'Bukti pembayaran diupload',
            'payment_validated' => 'Pembayaran divalidasi',
            'order_taken' => 'Barang diambil oleh pembeli',
            'campaign_cancelled' => 'Campaign dibatalkan',
            'distribution_completed' => 'Distribusi selesai',
            default => $this->action,
        };
    }
}
