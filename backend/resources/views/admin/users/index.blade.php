@extends('layouts.app')
@section('title','Kelola User')
@section('content')

<x-ui.page-header title="Kelola Role User" subtitle="Grant/revoke role akses." />

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'admin-users-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
