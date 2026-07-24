@extends('layouts.app')
@section('title','Pesanan Saya')
@section('content')

<x-ui.page-header title="Pesanan Saya" subtitle="Riwayat pesanan patungan Anda." />

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'orders-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush

@endsection
