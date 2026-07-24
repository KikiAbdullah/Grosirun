@extends('layouts.app')
@section('title','Produk')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Kelola Produk</h2>
        <p class="text-muted mb-0">Katalog produk supplier.</p>
    </div>
    <a href="{{ route('products.create') }}" class="btn btn-primary">Tambah</a>
</div>

<div class="card p-3">
    <div class="card-body p-0">
        {{ $dataTable->table(['id'=>'products-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush

@endsection
