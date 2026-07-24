@extends('layouts.app')
@section('title','Audit Log')
@section('content')

<x-ui.page-header title="Audit Log" subtitle="Append-only log.">
    <x-slot:actions>
        <span class="gr-badge gr-badge-neutral">
            <i data-lucide="lock" style="width:.75rem;height:.75rem"></i>Append-only
        </span>
    </x-slot:actions>
</x-ui.page-header>

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'audit-logs-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
