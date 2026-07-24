@extends('layouts.app')
@section('title','Offer')
@section('content')

<div class="d-flex align-items-center justify-content-between mb-4">
    <div>
        <h1 class="h3 fw-bold mb-1">Kelola Offer</h1>
        <p class="text-secondary mb-0">Penawaran harga tier.</p>
    </div>
    <div>
        <a href="{{ route('offers.create') }}" class="btn btn-primary">
            <i data-lucide="plus" style="width:1rem;height:1rem" class="me-1"></i>Buat Offer
        </a>
    </div>
</div>

<div class="card border-0 shadow-sm p-3">
<div class="card-body p-0">
    {{ $dataTable->table(['id'=>'offers-table','class'=>'table table-hover align-middle w-100']) }}
</div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
