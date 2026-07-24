@extends('layouts.app')
@section('title','Offer')
@section('content')

<x-ui.page-header title="Kelola Offer" subtitle="Penawaran harga tier.">
    <x-slot:actions>
        <x-ui.button variant="primary" href="{{ route('offers.create') }}" icon="plus">Buat Offer</x-ui.button>
    </x-slot:actions>
</x-ui.page-header>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'offers-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
