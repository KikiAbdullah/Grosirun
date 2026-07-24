@extends('layouts.app')
@section('title','Purchase Orders')
@section('content')

<x-ui.page-header title="Purchase Orders" subtitle="Daftar PO ke supplier.">
    <x-slot:actions>
        <x-ui.button variant="primary" href="{{ route('purchase-orders.create') }}" icon="plus">Buat PO</x-ui.button>
    </x-slot:actions>
</x-ui.page-header>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'pos-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
