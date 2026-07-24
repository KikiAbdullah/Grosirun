@extends('layouts.app')
@section('title','Verifikasi Supplier')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Verifikasi Supplier</h2>
        <p class="text-muted mb-0">Review dokumen usaha supplier.</p>
    </div>
</div>

<div class="card p-3">
    <div class="card-body p-0">
    {{ $dataTable->table(['id'=>'suppliers-table','class'=>'table table-hover align-middle w-100']) }}
    </div>
</div>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
<script>
document.addEventListener('click', function(e) {
    if (e.target.closest('.reject-btn')) {
        const btn = e.target.closest('.reject-btn');
        Swal.fire({
            title: 'Tolak Supplier',
            input: 'textarea',
            inputLabel: 'Alasan (wajib)',
            showCancelButton: true,
            confirmButtonColor: '#DC2626',
            confirmButtonText: 'Tolak',
            cancelButtonText: 'Batal'
        }).then(r => {
            if (r.isConfirmed && r.value) {
                const form = btn.closest('td').querySelector('form');
                form.querySelector('[name=reason]').value = r.value;
                form.submit();
            }
        });
    }
});
</script>
@endpush
@endsection
