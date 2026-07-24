@extends('layouts.app')
@section('title','Distribusi')
@section('content')

<x-ui.page-header title="Checklist Distribusi" subtitle="Centang buyer yang sudah ambil." />

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'distribution-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
