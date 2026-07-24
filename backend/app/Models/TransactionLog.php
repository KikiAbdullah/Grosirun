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
        'type',
        'initiator_id',
        'loggable_type',
        'loggable_id',
        'notes',
        'before_data',
        'after_data',
        'ip_address',
        'user_agent',
    ];

    protected $casts = [
        'before_data' => 'array',
        'after_data'  => 'array',
    ];

    /**
     * Get the user that performed the action
     */
    public function initiator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'initiator_id');
    }

    /**
     * Get the loggable model (polymorphic)
     */
    public function loggable(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Scope to filter by initiator
     */
    public function scopeByUser($query, int $userId)
    {
        return $query->where('initiator_id', $userId);
    }

    /**
     * Scope to filter by type
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Scope to filter by loggable type
     */
    public function scopeForType($query, string $loggableType)
    {
        return $query->where('loggable_type', $loggableType);
    }

    /**
     * Scope to order by latest
     */
    public function scopeLatest($query)
    {
        return $query->orderBy('created_at', 'desc');
    }

    /**
     * Get description of the log type
     */
    public function getDescriptionAttribute(): string
    {
        return match($this->type) {
            'order_created'          => 'Pesanan dibuat',
            'proof_uploaded'         => 'Bukti pembayaran diupload',
            'payment_validated'      => 'Pembayaran divalidasi',
            'order_taken'            => 'Barang diambil oleh pembeli',
            'campaign_cancelled'     => 'Campaign dibatalkan',
            'distribution_completed' => 'Distribusi selesai',
            default                  => $this->type,
        };
    }
}
