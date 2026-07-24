@extends('layouts.app')
@section('title','Audit Log')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Audit Log</h2>
        <p class="text-muted mb-0">Append-only log.</p>
    </div>
    <div>
        <span class="badge bg-secondary">
            <i data-lucide="lock" style="width:.75rem;height:.75rem"></i>Append-only
        </span>
    </div>
</div>

<div class="card p-3">
    <div class="card-body p-0">
    {{ $dataTable->table(['id'=>'audit-logs-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
