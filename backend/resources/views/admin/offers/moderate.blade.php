@extends('layouts.app')
@section('title','Moderasi Offer')
@section('content')

<x-ui.page-header title="Moderasi Offer" subtitle="Review tier harga &amp; kapasitas." />

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'moderate-offers-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
