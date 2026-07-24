@extends('layouts.app')
@section('title','Edit Campaign')
@section('content')

<div class="d-flex flex-column mb-4">
    <h1 class="h3 fw-bold mb-1">Edit Campaign</h1>
</div>

<div class="card border-0 shadow-sm">
<div class="card-body">
    <form method="POST" action="{{ route('campaigns.update',$uuid) }}">
        @csrf @method('PUT')

        <div class="mb-3">
            <label class="form-label fw-semibold">Judul <span class="text-danger">*</span></label>
            <input type="text" name="title" class="gr-form-input" value="Beras Premium Pulen" required>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Target</label>
            <input type="number" name="target_quantity" class="gr-form-input" value="500">
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('campaigns.manage') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">
                <i data-lucide="save" style="width:1rem;height:1rem" class="me-1"></i>Simpan
            </button>
        </div>
    </form>
</div>
</div>
@endsection
