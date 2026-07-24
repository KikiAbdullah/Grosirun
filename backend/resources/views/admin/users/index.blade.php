@extends('layouts.app')
@section('title','Kelola User')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Kelola Role User</h2>
        <p class="text-muted mb-0">Grant/revoke role akses.</p>
    </div>
</div>

<div class="card p-3">
    <div class="card-body p-0">
    {{ $dataTable->table(['id'=>'admin-users-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
