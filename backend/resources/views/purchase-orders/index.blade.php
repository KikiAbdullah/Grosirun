@extends('layouts.app')
@section('title','Purchase Orders')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Purchase Orders</h2>
        <p class="text-muted mb-0">Daftar PO ke supplier.</p>
    </div>
    <a href="{{ route('purchase-orders.create') }}" class="btn btn-primary">Buat PO</a>
</div>

<div class="card p-3">
    <div class="card-body p-0">
        {{ $dataTable->table(['id'=>'pos-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
