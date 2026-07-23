<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PurchaseOrderDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'purchase_order_id',
        'type',
        'file_path',
        'file_url',
        'uploaded_at',
    ];

    protected $casts = [
        'uploaded_at' => 'datetime',
    ];

    /**
     * Get the purchase order that owns this document
     */
    public function purchaseOrder(): BelongsTo
    {
        return $this->belongsTo(PurchaseOrder::class);
    }

    /**
     * Check if document is invoice
     */
    public function isInvoice(): bool
    {
        return $this->type === 'invoice';
    }

    /**
     * Check if document is surat_jalan
     */
    public function isSuratJalan(): bool
    {
        return $this->type === 'surat_jalan';
    }

    /**
     * Scope to filter invoices
     */
    public function scopeInvoices($query)
    {
        return $query->where('type', 'invoice');
    }

    /**
     * Scope to filter surat jalan
     */
    public function scopeSuratJalan($query)
    {
        return $query->where('type', 'surat_jalan');
    }
}
