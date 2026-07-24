@extends('layouts.app')
@section('title','Dashboard')
@section('content')

<x-ui.page-header title="Dashboard" subtitle="Ringkasan aktivitas dan metrik utama." />

{{-- Metric Cards --}}
<div class="row g-3 mb-4">
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <div class="d-flex align-items-center justify-content-center rounded-3"
                     style="width:2.5rem;height:2.5rem;background:var(--primary-50)">
                    <i data-lucide="shopping-cart" style="width:1.25rem;height:1.25rem;color:var(--primary-500)"></i>
                </div>
                <span class="gr-badge gr-badge-success">
                    <i data-lucide="trending-up" style="width:.75rem;height:.75rem"></i>Aktif
                </span>
            </div>
            <p class="metric-value">3</p>
            <p class="metric-label mb-0">Campaign Aktif</p>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--info-50)">
                <i data-lucide="receipt" style="width:1.25rem;height:1.25rem;color:var(--info-500)"></i>
            </div>
            <p class="metric-value">24</p>
            <p class="metric-label mb-0">Total Pesanan</p>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--warning-50)">
                <i data-lucide="clock" style="width:1.25rem;height:1.25rem;color:var(--warning-500)"></i>
            </div>
            <p class="metric-value">5</p>
            <p class="metric-label mb-0">Menunggu Validasi</p>
        </div>
    </div>
    <div class="col-6 col-lg-3">
        <div class="gr-card p-3">
            <div class="d-flex align-items-center justify-content-center rounded-3 mb-3"
                 style="width:2.5rem;height:2.5rem;background:var(--primary-50)">
                <i data-lucide="users" style="width:1.25rem;height:1.25rem;color:var(--primary-500)"></i>
            </div>
            <p class="metric-value">18</p>
            <p class="metric-label mb-0">Partisipan</p>
        </div>
    </div>
</div>

{{-- Main Content --}}
<div class="row g-4">
    {{-- Campaigns --}}
    <div class="col-12 col-lg-8">
        <div class="gr-card p-3 p-sm-4">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <h2 class="fw-semibold mb-0" style="font-size:1.05rem">Campaign Berjalan</h2>
                <x-ui.button variant="ghost" size="sm" href="{{ route('campaigns.index') }}" icon="arrow-right">
                    Lihat Semua
                </x-ui.button>
            </div>
            <div class="d-flex flex-column gap-3">
                @foreach([
                    ['title'=>'Beras Premium Pulen','progress'=>64,'current'=>'320','target'=>'500 kg','deadline'=>now()->addDays(3)],
                    ['title'=>'Minyak Goreng 2L','progress'=>73,'current'=>'145','target'=>'200 pcs','deadline'=>now()->addDays(5)],
                    ['title'=>'Telur Ayam Negeri','progress'=>78,'current'=>'780','target'=>'1000 butir','deadline'=>now()->addDays(2)],
                ] as $c)
                <a href="#" class="gr-card gr-card-hover p-3 text-decoration-none"
                   style="border:1px solid var(--surface-200)">
                    <div class="d-flex align-items-start justify-content-between mb-2">
                        <h3 class="fw-semibold mb-0" style="font-size:.95rem;color:var(--text-primary)">{{ $c['title'] }}</h3>
                        <span class="gr-badge gr-badge-info">PGH-RT03</span>
                    </div>
                    <div class="gr-progress mb-2">
                        <div class="{{ $c['progress'] >= 70 ? 'gr-progress-fill gr-progress-yellow' : 'gr-progress-fill gr-progress-green' }}"
                             style="width:{{ $c['progress'] }}%">{{ $c['progress'] }}%</div>
                    </div>
                    <div class="d-flex align-items-center justify-content-between">
                        <span style="font-size:.8rem;color:var(--text-secondary)">{{ $c['current'] }}/{{ $c['target'] }}</span>
                        <span class="fw-semibold" style="font-size:.8rem"
                              x-data="countdown('{{ $c['deadline']->toISOString() }}')"
                              x-text="remaining"
                              :style="isUrgent ? 'color:var(--danger-600)' : 'color:var(--text-secondary)'"></span>
                    </div>
                </a>
                @endforeach
            </div>
        </div>
    </div>

    {{-- Sidebar --}}
    <div class="col-12 col-lg-4">
        <div class="d-flex flex-column gap-4">
            {{-- Profile Card --}}
            <div class="gr-card p-3 p-sm-4">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold"
                         style="width:3.5rem;height:3.5rem;background:var(--primary-500);font-size:1.25rem;flex-shrink:0">BS</div>
                    <div>
                        <h3 class="fw-semibold mb-0" style="font-size:.95rem">Bu Siti Rahayu</h3>
                        <p class="mb-0" style="font-size:.8rem;color:var(--text-secondary)">PGH-RT03</p>
                    </div>
                </div>
                <div class="d-flex gap-2">
                    <span class="gr-badge gr-badge-info">Buyer</span>
                    <span class="gr-badge gr-badge-success">
                        <i data-lucide="check-circle" style="width:.75rem;height:.75rem"></i>Consent
                    </span>
                </div>
            </div>

            {{-- Quick Actions --}}
            <div class="gr-card p-3 p-sm-4">
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Aksi Cepat</h3>
                <div class="d-flex flex-column gap-2">
                    <x-ui.button variant="primary" href="{{ route('campaigns.index') }}" icon="shopping-cart" class="w-100">
                        Lihat Campaign
                    </x-ui.button>
                    <x-ui.button variant="secondary" href="{{ route('orders.index') }}" icon="receipt" class="w-100">
                        Pesanan Saya
                    </x-ui.button>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection
