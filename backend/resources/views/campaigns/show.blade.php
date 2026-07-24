@extends('layouts.app')
@section('title','Detail Campaign')
@section('content')

<div class="d-flex align-items-center justify-content-between mb-4">
    <div>
        <h1 class="h3 fw-bold mb-1">Beras Premium Pulen</h1>
        <p class="text-secondary mb-0">oleh Pak Agus Setiawan • PGH-RT03</p>
    </div>
    <div>
        <button class="btn btn-light btn-sm">
            <i data-lucide="share-2" style="width:1rem;height:1rem" class="me-1"></i>Share
        </button>
    </div>
</div>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <div class="card border-0 shadow-sm">
        <div class="card-body">
            {{-- Product Image --}}
            <div class="rounded-3 d-flex align-items-center justify-content-center mb-4"
                 style="aspect-ratio:16/9;background:linear-gradient(135deg,var(--primary-50),var(--primary-100))">
                <i data-lucide="image" style="width:4rem;height:4rem;color:var(--primary-300, #86efac)"></i>
            </div>

            {{-- Progress --}}
            <div class="gr-progress mb-3">
                <div class="gr-progress-fill gr-progress-yellow" style="width:64%">64%</div>
            </div>

            <p class="mb-4" style="font-size:.875rem;color:var(--text-secondary)">
                Beras premium kualitas terbaik langsung dari pabrik Makmur Jaya.
            </p>

            <h3 class="fw-semibold mb-3" style="font-size:.95rem">Pilih Varian</h3>
            @foreach([
                ['name'=>'5 Kg','remaining'=>20,'price'=>60000],
                ['name'=>'10 Kg','remaining'=>10,'price'=>120000],
                ['name'=>'25 Kg (Sak)','remaining'=>4,'price'=>300000],
            ] as $v)
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 border mb-2"
                 style="border-color:var(--surface-200)"
                 x-data="{qty:0}">
                <div>
                    <p class="fw-semibold mb-0" style="font-size:.875rem">{{ $v['name'] }}</p>
                    <p class="mb-0" style="font-size:.75rem;color:var(--text-secondary)">Sisa {{ $v['remaining'] }}</p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button @click="qty=Math.max(0,qty-1)" class="gr-btn-icon" style="background:var(--surface-100)">
                        <i data-lucide="minus" style="width:1rem;height:1rem"></i>
                    </button>
                    <span class="fw-semibold text-center" style="min-width:2rem" x-text="qty"></span>
                    <button @click="qty=Math.min({{ $v['remaining'] }},qty+1)"
                            class="gr-btn-icon text-white" style="background:var(--primary-500)">
                        <i data-lucide="plus" style="width:1rem;height:1rem"></i>
                    </button>
                </div>
            </div>
            @endforeach
        </div>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <div class="d-flex flex-column gap-4">
            {{-- Metode Pembayaran --}}
            <div class="card border-0 shadow-sm">
            <div class="card-body">
                <h3 class="fw-semibold mb-3" style="font-size:.95rem">Metode Pembayaran</h3>
                <div class="row g-2">
                    <div class="col-6">
                        <label class="d-block p-3 rounded-3 text-center"
                               style="border:2px solid var(--primary-500);background:var(--primary-50);cursor:pointer">
                            <i data-lucide="banknote" style="width:1.5rem;height:1.5rem;color:var(--primary-500);display:block;margin:0 auto .25rem"></i>
                            <span class="fw-semibold" style="font-size:.875rem">Tunai</span>
                        </label>
                    </div>
                    <div class="col-6">
                        <label class="d-block p-3 rounded-3 text-center"
                               style="border:1px solid var(--surface-200);cursor:pointer"
                               onmouseover="this.style.borderColor='var(--primary-300)'" onmouseout="this.style.borderColor='var(--surface-200)'">
                            <i data-lucide="qr-code" style="width:1.5rem;height:1.5rem;color:var(--text-secondary);display:block;margin:0 auto .25rem"></i>
                            <span class="fw-semibold" style="font-size:.875rem">QRIS</span>
                        </label>
                    </div>
                </div>
            </div>
            </div>

            {{-- Checkout --}}
            <div class="card border-0 shadow-sm">
            <div class="card-body">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <span style="font-size:.875rem;color:var(--text-secondary)">Total</span>
                    <span class="fw-bold" style="font-size:1.5rem;color:var(--primary-500)">Rp60.000</span>
                </div>
                <button class="btn btn-primary w-100 gr-btn-lg">
                    <i data-lucide="shopping-cart" style="width:1rem;height:1rem" class="me-1"></i>Checkout
                </button>
            </div>
            </div>
        </div>
    </div>
</div>
@endsection
