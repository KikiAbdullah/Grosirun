@extends('layouts.app')
@section('title','Buat Campaign')
@section('content')

<div class="d-flex flex-column mb-4">
    <h1 class="h3 fw-bold mb-1">Buat Campaign Baru</h1>
    <p class="text-secondary mb-0">Isi detail campaign patungan.</p>
</div>

<div class="card border-0 shadow-sm">
<div class="card-body">
    <form method="POST" action="{{ route('campaigns.store') }}">
        @csrf

        <div class="mb-3">
            <label class="form-label fw-semibold">Judul Campaign <span class="text-danger">*</span></label>
            <input type="text" name="title" class="gr-form-input" placeholder="Beras Premium Pulen" required>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Deskripsi</label>
            <textarea name="description" class="gr-form-input" rows="3" placeholder="Deskripsi campaign..."></textarea>
        </div>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Target Quantity <span class="text-danger">*</span></label>
                    <input type="number" name="target_quantity" class="gr-form-input" placeholder="1000" required>
                </div>
            </div>
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Satuan <span class="text-danger">*</span></label>
                    <select name="unit" class="gr-form-input" required>
                        <option value="kg">Kg</option>
                        <option value="pcs">Pcs</option>
                        <option value="liter">Liter</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Harga Buyer / unit <span class="text-danger">*</span></label>
                    <input type="number" name="buyer_unit_price" class="gr-form-input" placeholder="12000" required>
                </div>
            </div>
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Tenggat (hari) <span class="text-danger">*</span></label>
                    <input type="number" name="deadline_days" class="gr-form-input" placeholder="2" min="1" required>
                </div>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Lokasi Distribusi <span class="text-danger">*</span></label>
            <input type="text" name="location" class="gr-form-input" placeholder="Rumah Pak RT Jl Mawar 12" required>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('campaigns.index') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">
                <i data-lucide="send" style="width:1rem;height:1rem" class="me-1"></i>Publikasikan
            </button>
        </div>
    </form>
</div>
</div>
@endsection
