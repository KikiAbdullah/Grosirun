@extends('layouts.app')
@section('title','Admin Dashboard')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Console Admin</h2>
        <p class="text-muted mb-0">Moderasi dan audit terpusat.</p>
    </div>
</div>

{{-- Metrics --}}
<div class="row g-3 mb-4">
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--warning-50)">
                <i data-lucide="store" style="width:1.25rem;height:1.25rem;color:var(--warning-600)"></i>
            </div>
            <p class="metric-value">{{ $metrics['pending_suppliers'] ?? 0 }}</p>
            <p class="metric-label mb-0">Pending Supplier</p>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--info-50)">
                <i data-lucide="tags" style="width:1.25rem;height:1.25rem;color:var(--info-500)"></i>
            </div>
            <p class="metric-value">{{ $metrics['pending_offers'] ?? 0 }}</p>
            <p class="metric-label mb-0">Pending Offer</p>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--danger-50)">
                <i data-lucide="alert-triangle" style="width:1.25rem;height:1.25rem;color:var(--danger-600)"></i>
            </div>
            <p class="metric-value">{{ $metrics['open_disputes'] ?? 0 }}</p>
            <p class="metric-label mb-0">Open Dispute</p>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--primary-50)">
                <i data-lucide="activity" style="width:1.25rem;height:1.25rem;color:var(--primary-500)"></i>
            </div>
            <p class="metric-value">{{ $metrics['total_users'] ?? 0 }}</p>
            <p class="metric-label mb-0">Total User</p>
        </div>
    </div>
</div>

{{-- Quick Links --}}
<div class="row g-3">
    @foreach([
        ['route'=>'admin.suppliers.pending','icon'=>'shield-check','color'=>'var(--warning-50)','icon_color'=>'var(--warning-600)','title'=>'Verifikasi Supplier','count'=>($metrics['pending_suppliers'] ?? 0).' menunggu'],
        ['route'=>'admin.offers.moderate','icon'=>'clipboard-check','color'=>'var(--info-50)','icon_color'=>'var(--info-500)','title'=>'Moderasi Offer','count'=>($metrics['pending_offers'] ?? 0).' perlu review'],
        ['route'=>'admin.users.index','icon'=>'users','color'=>'var(--primary-50)','icon_color'=>'var(--primary-500)','title'=>'Kelola Role','count'=>'Grant/revoke akses user'],
        ['route'=>'admin.disputes.index','icon'=>'gavel','color'=>'var(--danger-50)','icon_color'=>'var(--danger-600)','title'=>'Mediasi Dispute','count'=>($metrics['open_disputes'] ?? 0).' terbuka'],
        ['route'=>'admin.audit-logs','icon'=>'history','color'=>'var(--surface-100)','icon_color'=>'var(--text-secondary)','title'=>'Audit Log','count'=>'Riwayat semua aksi admin'],
    ] as $item)
    <div class="col-12 col-sm-6 col-lg-4">
        <a href="{{ route($item['route']) }}"
           class="gr-card gr-card-hover p-3 p-sm-4 d-flex align-items-start gap-3 text-decoration-none">
            <div class="d-flex align-items-center justify-content-center rounded-3 flex-shrink-0"
                 style="width:3rem;height:3rem;background:{{ $item['color'] }}">
                <i data-lucide="{{ $item['icon'] }}" style="width:1.5rem;height:1.5rem;color:{{ $item['icon_color'] }}"></i>
            </div>
            <div>
                <h3 class="fw-semibold mb-1" style="font-size:.95rem;color:var(--text-primary)">{{ $item['title'] }}</h3>
                <p class="mb-0" style="font-size:.8rem;color:var(--text-secondary)">{{ $item['count'] }}</p>
            </div>
        </a>
    </div>
    @endforeach
</div>
@endsection
