@extends('layouts.app')
@section('title','Dashboard')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Dashboard</h2>
        <p class="text-muted mb-0">Ringkasan aktivitas Anda.</p>
    </div>
</div>

@php
$cards = match($role) {
    'admin' => [
        ['icon'=>'store','label'=>'Pending Supplier','value'=>$metrics['pending_suppliers'],'color'=>'var(--warning-50)','text_color'=>'var(--warning-600)','route'=>route('admin.suppliers.pending')],
        ['icon'=>'tags','label'=>'Pending Offer','value'=>$metrics['pending_offers'],'color'=>'var(--info-50)','text_color'=>'var(--info-500)','route'=>route('admin.offers.moderate')],
        ['icon'=>'alert-triangle','label'=>'Open Dispute','value'=>$metrics['open_disputes'],'color'=>'var(--danger-50)','text_color'=>'var(--danger-600)','route'=>route('admin.disputes.index')],
        ['icon'=>'users','label'=>'Total User','value'=>$metrics['total_users'],'color'=>'var(--primary-50)','text_color'=>'var(--primary-500)','route'=>route('admin.users.index')],
    ],
    'initiator' => [
        ['icon'=>'shopping-cart','label'=>'Campaign Aktif','value'=>$metrics['active_campaigns'],'color'=>'var(--primary-50)','text_color'=>'var(--primary-500)','route'=>route('campaigns.manage')],
        ['icon'=>'clock','label'=>'Menunggu Validasi','value'=>$metrics['pending_validation'],'color'=>'var(--warning-50)','text_color'=>'var(--warning-600)','route'=>route('orders.validate')],
        ['icon'=>'file-text','label'=>'PO Pending','value'=>$metrics['pending_pos'],'color'=>'var(--info-50)','text_color'=>'var(--info-500)','route'=>route('purchase-orders.index')],
        ['icon'=>'truck','label'=>'Belum Diambil','value'=>$metrics['not_taken'],'color'=>'var(--danger-50)','text_color'=>'var(--danger-600)','route'=>route('distribution.index')],
    ],
    'seller' => [
        ['icon'=>'package','label'=>'Produk','value'=>$metrics['total_products'],'color'=>'var(--primary-50)','text_color'=>'var(--primary-500)','route'=>route('products.index')],
        ['icon'=>'tags','label'=>'Offer Aktif','value'=>$metrics['active_offers'],'color'=>'var(--info-50)','text_color'=>'var(--info-500)','route'=>route('offers.index')],
        ['icon'=>'file-plus','label'=>'PO Baru','value'=>$metrics['pending_pos'],'color'=>'var(--warning-50)','text_color'=>'var(--warning-600)','route'=>route('purchase-orders.index')],
        ['icon'=>'truck','label'=>'Processing','value'=>$metrics['processing_pos'],'color'=>'var(--primary-50)','text_color'=>'var(--primary-500)','route'=>route('purchase-orders.index')],
    ],
    default => [
        ['icon'=>'shopping-cart','label'=>'Campaign Aktif','value'=>$metrics['active_campaigns'],'color'=>'var(--primary-50)','text_color'=>'var(--primary-500)','route'=>route('campaigns.index')],
        ['icon'=>'receipt','label'=>'Pesanan Saya','value'=>$metrics['my_orders'],'color'=>'var(--info-50)','text_color'=>'var(--info-500)','route'=>route('orders.index')],
        ['icon'=>'clock','label'=>'Menunggu Bayar','value'=>$metrics['pending_payment'],'color'=>'var(--warning-50)','text_color'=>'var(--warning-600)','route'=>route('orders.index')],
        ['icon'=>'truck','label'=>'Siap Diambil','value'=>$metrics['not_taken'],'color'=>'var(--primary-50)','text_color'=>'var(--primary-500)','route'=>route('orders.index')],
    ],
};
@endphp

<div class="row g-3 mb-4">
    @foreach($cards as $card)
    <div class="col-6 col-lg-3">
        <a href="{{ $card['route'] }}" class="text-decoration-none">
            <div class="gr-card p-3 h-100" style="cursor:pointer">
                <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                     style="width:2.5rem;height:2.5rem;background:{{ $card['color'] }}">
                    <i data-lucide="{{ $card['icon'] }}" style="width:1.25rem;height:1.25rem;color:{{ $card['text_color'] }}"></i>
                </div>
                <h3 class="fw-bold mb-1" style="font-size:1.5rem;color:{{ $card['text_color'] }}">{{ number_format($card['value']) }}</h3>
                <p class="text-muted mb-0" style="font-size:.8rem">{{ $card['label'] }}</p>
            </div>
        </a>
    </div>
    @endforeach
</div>

{{-- Revenue Card --}}
@if(isset($metrics['total_revenue']) || isset($metrics['gmv_total']))
<div class="row g-3 mb-4">
    <div class="col-12">
        <div class="gr-card p-4">
            <div class="d-flex align-items-center justify-content-between">
                <div>
                    <p class="text-muted mb-1">{{ $role === 'admin' ? 'Total GMV' : 'Total Revenue' }}</p>
                    <h2 class="fw-bold mb-0 text-primary">Rp{{ number_format($metrics['total_revenue'] ?? $metrics['gmv_total'] ?? 0, 0, ',', '.') }}</h2>
                </div>
                <div class="text-end">
                    @if($role === 'buyer' && isset($metrics['total_spent']))
                    <p class="text-muted mb-1">Total Belanja</p>
                    <h3 class="fw-bold mb-0">Rp{{ number_format($metrics['total_spent'], 0, ',', '.') }}</h3>
                    @elseif($role === 'initiator')
                    <p class="text-muted mb-1">Diterima: {{ $metrics['paid_orders'] }} | Diambil: {{ $metrics['taken'] ?? 0 }}</p>
                    @elseif($role === 'seller')
                    <p class="text-muted mb-1">Selesai: {{ $metrics['completed_pos'] }}</p>
                    @else
                    <p class="text-muted mb-1">Orders hari ini: {{ $metrics['today_orders'] ?? 0 }}</p>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endif

{{-- Quick Actions --}}
<div class="row g-3">
    <div class="col-12">
        <div class="gr-card p-4">
            <h5 class="fw-bold mb-3">Aksi Cepat</h5>
            <div class="d-flex flex-wrap gap-2">
                @if($role === 'buyer')
                <a href="{{ route('campaigns.index') }}" class="btn btn-primary btn-sm"><i data-lucide="shopping-cart" class="me-1" style="width:14px;height:14px"></i>Lihat Campaign</a>
                <a href="{{ route('orders.index') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="receipt" class="me-1" style="width:14px;height:14px"></i>Pesanan Saya</a>
                @elseif($role === 'initiator')
                <a href="{{ route('campaigns.create') }}" class="btn btn-primary btn-sm"><i data-lucide="plus" class="me-1" style="width:14px;height:14px"></i>Buat Campaign</a>
                <a href="{{ route('orders.validate') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="check-square" class="me-1" style="width:14px;height:14px"></i>Validasi Order</a>
                <a href="{{ route('distribution.index') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="truck" class="me-1" style="width:14px;height:14px"></i>Distribusi</a>
                @elseif($role === 'seller')
                <a href="{{ route('products.create') }}" class="btn btn-primary btn-sm"><i data-lucide="plus" class="me-1" style="width:14px;height:14px"></i>Tambah Produk</a>
                <a href="{{ route('offers.create') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="tags" class="me-1" style="width:14px;height:14px"></i>Buat Offer</a>
                <a href="{{ route('purchase-orders.index') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="file-text" class="me-1" style="width:14px;height:14px"></i>Purchase Orders</a>
                @else
                <a href="{{ route('admin.suppliers.pending') }}" class="btn btn-primary btn-sm"><i data-lucide="shield-check" class="me-1" style="width:14px;height:14px"></i>Verifikasi Supplier</a>
                <a href="{{ route('admin.offers.moderate') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="clipboard-check" class="me-1" style="width:14px;height:14px"></i>Moderasi Offer</a>
                <a href="{{ route('admin.audit-logs') }}" class="btn btn-outline-primary btn-sm"><i data-lucide="history" class="me-1" style="width:14px;height:14px"></i>Audit Log</a>
                @endif
            </div>
        </div>
    </div>
</div>

@endsection
