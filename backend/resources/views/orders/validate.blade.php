@extends('layouts.app')
@section('title','Validasi Pembayaran')
@section('content')

<x-ui.page-header title="Validasi Pembayaran" subtitle="Review pembayaran buyer." />

<div class="gr-card p-3 mb-4 d-flex align-items-start gap-2" style="background:var(--primary-50);border:1px solid var(--primary-100)">
    <i data-lucide="info" style="width:1.25rem;height:1.25rem;color:var(--primary-500);flex-shrink:0;margin-top:.1rem"></i>
    <p class="mb-0" style="font-size:.875rem;color:var(--primary-700)">Validasi pembayaran tunai/QRIS. Periksa bukti sebelum approve.</p>
</div>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'validate-orders-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush

@endsection
