@extends('layouts.app')
@section('title','Edit Offer')
@section('content')

<div class="d-flex flex-column mb-4">
    <h1 class="h3 fw-bold mb-1">Edit Offer</h1>
</div>

<div class="card border-0 shadow-sm">
<div class="card-body">
    <form method="POST" action="{{ route('offers.update',$id) }}">
        @csrf @method('PUT')

        <div class="mb-3">
            <label class="form-label fw-semibold">Produk</label>
            <select name="product_id" class="gr-form-input">
                <option value="1" selected>Beras Premium Pulen</option>
            </select>
        </div>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Min Order</label>
                    <input type="number" name="minimum_order" class="gr-form-input" value="500">
                </div>
            </div>
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Kapasitas</label>
                    <input type="number" name="capacity" class="gr-form-input" value="2000">
                </div>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Area Layanan</label>
            <div x-data="tomSelectWrapper({maxItems:null})">
                <select name="service_areas[]" x-ref="select" multiple class="gr-form-input">
                    <option value="PGH-RT03" selected>PGH-RT03</option>
                    <option value="PGH-RT05" selected>PGH-RT05</option>
                </select>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('offers.index') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">
                <i data-lucide="save" style="width:1rem;height:1rem" class="me-1"></i>Simpan
            </button>
        </div>
    </form>
</div>
</div>
@endsection
