@extends('layouts.app')
@section('title','Kelola Campaign')
@section('content')

<x-ui.page-header title="Kelola Campaign" subtitle="Campaign yang Anda inisiasi.">
    <x-slot:actions>
        <x-ui.button variant="primary" href="{{ route('campaigns.create') }}" icon="plus">Buat Baru</x-ui.button>
    </x-slot:actions>
</x-ui.page-header>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'campaigns-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
