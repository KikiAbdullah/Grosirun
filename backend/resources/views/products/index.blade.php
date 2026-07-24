@extends('layouts.app')
@section('title','Produk')
@section('content')

<x-ui.page-header title="Kelola Produk" subtitle="Katalog produk supplier.">
    <x-slot:actions>
        <x-ui.button variant="primary" href="{{ route('products.create') }}" icon="plus">Tambah</x-ui.button>
    </x-slot:actions>
</x-ui.page-header>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'products-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush

@endsection
