@extends('layouts.app')
@section('title','Moderasi Offer')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Moderasi Offer</h2>
        <p class="text-muted mb-0">Review tier harga &amp; kapasitas.</p>
    </div>
</div>

<div class="card p-3">
    <div class="card-body p-0">
    {{ $dataTable->table(['id'=>'moderate-offers-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
