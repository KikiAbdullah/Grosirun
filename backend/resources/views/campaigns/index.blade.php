@extends('layouts.app')
@section('title','Campaign')
@section('content')

<div class="d-flex align-items-center justify-content-between mb-4">
    <div>
        <h1 class="h3 fw-bold mb-1">Campaign Patungan</h1>
        <p class="text-secondary mb-0">Daftar campaign aktif di cluster Anda.</p>
    </div>
    <div>
        <a href="{{ route('campaigns.create') }}" class="btn btn-primary">
            <i data-lucide="plus" style="width:1rem;height:1rem" class="me-1"></i>Buat Campaign
        </a>
    </div>
</div>

<div class="card border-0 shadow-sm p-3">
<div class="card-body p-0">
    {{ $dataTable->table(['id'=>'campaigns-table','class'=>'table table-hover align-middle w-100']) }}
</div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
