@extends('layouts.app')
@section('title','Campaign')
@section('content')

<x-ui.page-header title="Campaign Patungan" subtitle="Daftar campaign aktif di cluster Anda.">
    <x-slot:actions>
        <x-ui.button variant="primary" href="{{ route('campaigns.create') }}" icon="plus">Buat Campaign</x-ui.button>
    </x-slot:actions>
</x-ui.page-header>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'campaigns-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
