@extends('layouts.app')
@section('title','Syarat Layanan')
@section('content')

<div class="mx-auto" style="max-width:40rem" x-data="{scrolled:false}" @scroll.window="scrolled=(window.scrollY>200)">
    <div class="card p-4"><div class="card-body">
        <div class="d-flex align-items-center gap-3 mb-4">
            <div class="d-flex align-items-center justify-content-center rounded-3 flex-shrink-0"
                 style="width:3rem;height:3rem;background:var(--warning-50)">
                <i data-lucide="file-text" style="width:1.5rem;height:1.5rem;color:var(--warning-600)"></i>
            </div>
            <div>
                <h1 class="fw-bold mb-0" style="font-size:1.25rem;color:var(--text-primary)">Syarat Layanan Non-Escrow</h1>
                <p class="mb-0" style="font-size:.875rem;color:var(--text-secondary)">Wajib dibaca</p>
            </div>
        </div>

        <div class="overflow-y-auto border rounded-3 p-3 mb-4"
             style="max-height:20rem;background:var(--surface-50);color:var(--text-secondary);font-size:.875rem">
            <h3 class="fw-bold mb-2" style="font-size:.95rem;color:var(--text-primary)">1. Model Non-Escrow</h3>
            <p class="mb-3">Grosirun <strong>bukan marketplace atau bank</strong>. Dana tidak ditahan oleh aplikasi.</p>

            <h3 class="fw-bold mb-2" style="font-size:.95rem;color:var(--text-primary)">2. Alur Pembayaran</h3>
            <p class="mb-3">Buyer membayar <strong>langsung ke Initiator</strong> (tunai/QRIS). Initiator transfer ke Supplier.</p>

            <h3 class="fw-bold mb-2" style="font-size:.95rem;color:var(--text-primary)">3. Penyelesaian Sengketa</h3>
            <ul class="ps-3 mb-3" style="line-height:1.8">
                <li>Buyer ↔ Initiator: <strong>2×24 jam</strong></li>
                <li>Eskalasi RT/RW: <strong>3×24 jam</strong></li>
                <li>Admin mediasi berdasarkan bukti</li>
            </ul>

            <h3 class="fw-bold mb-2" style="font-size:.95rem;color:var(--text-primary)">4. Privasi Data</h3>
            <p class="mb-0">Data Buyer <strong>tidak dapat dilihat Seller</strong>. Audit log append-only.</p>
        </div>

        <div x-show="!scrolled" x-transition class="text-center mb-3">
            <p style="font-size:.75rem;color:var(--text-disabled)">
                <i data-lucide="arrow-down" style="width:1rem;height:1rem;display:inline-block;vertical-align:middle"></i>
                Scroll untuk membaca semua
            </p>
        </div>

        <form method="POST" action="{{ route('tos.accept') }}">
            @csrf
            <label class="d-flex align-items-start gap-2 mb-4" style="cursor:pointer">
                <input type="checkbox" name="agree" :disabled="!scrolled" required
                       class="mt-1 form-check-input flex-shrink-0"
                       style="accent-color:var(--primary-500)">
                <span style="font-size:.875rem" :style="!scrolled ? 'opacity:.5' : ''">
                    Saya <strong>mengerti dan setuju</strong>.
                </span>
            </label>
            <button type="submit" class="btn btn-primary w-100"><i data-lucide="check" style="width:1rem;height:1rem" class="me-2"></i>Setuju &amp; Lanjutkan</button>
        </form>
    </div></div>
</div>

@endsection
