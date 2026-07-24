@extends('layouts.app')
@section('title','Recap Campaign')
@section('content')

<x-ui.page-header title="Recap: Beras Premium Pulen" />

<div class="row g-3 mb-4">
    <div class="col-12 col-sm-4">
        <div class="gr-card p-3">
            <p class="metric-value">500 Kg</p>
            <p class="metric-label mb-0">Target Tercapai</p>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="gr-card p-3">
            <p class="metric-value">Rp6.000.000</p>
            <p class="metric-label mb-0">Total Pembelian Buyer</p>
        </div>
    </div>
    <div class="col-12 col-sm-4">
        <div class="gr-card p-3">
            <p class="metric-value">Rp5.250.000</p>
            <p class="metric-label mb-0">Subtotal Supplier</p>
        </div>
    </div>
</div>

<x-ui.card>
    <h3 class="fw-semibold mb-3" style="font-size:1rem">Detail per Varian</h3>
    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead style="background:var(--surface-50)">
                <tr>
                    <th style="font-size:.75rem;color:var(--text-secondary);text-transform:uppercase">Varian</th>
                    <th style="font-size:.75rem;color:var(--text-secondary);text-transform:uppercase">Terjual</th>
                    <th style="font-size:.75rem;color:var(--text-secondary);text-transform:uppercase">Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <tr><td>5 Kg</td><td>30 paket</td><td>Rp1.800.000</td></tr>
                <tr><td>10 Kg</td><td>20 paket</td><td>Rp2.400.000</td></tr>
                <tr><td>25 Kg (Sak)</td><td>6 sak</td><td>Rp1.800.000</td></tr>
            </tbody>
        </table>
    </div>
</x-ui.card>

<div class="d-flex justify-content-end mt-4">
    <x-ui.button variant="primary" href="{{ route('purchase-orders.create') }}" icon="file-text">
        Buat PO ke Seller
    </x-ui.button>
</div>
@endsection
