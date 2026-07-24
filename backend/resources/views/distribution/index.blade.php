@extends('layouts.app')
@section('title','Distribusi')
@section('content')

<div class="mb-4">
    <h2 class="h4 mb-1">Checklist Distribusi</h2>
    <p class="text-muted mb-0">Centang buyer yang sudah ambil.</p>
</div>

<div class="card p-3">
    <div class="card-body p-0">
        {{ $dataTable->table(['id'=>'distribution-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
