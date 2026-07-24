@extends('layouts.app')
@section('title','Buat Offer')
@section('content')

<div class="d-flex flex-column mb-4">
    <h1 class="h3 fw-bold mb-1">Buat Offer Baru</h1>
    <p class="text-secondary mb-0">Tentukan harga tier dan area layanan.</p>
</div>

<div class="card border-0 shadow-sm">
<div class="card-body">
    <form method="POST" action="{{ route('offers.store') }}">
        @csrf

        <div class="mb-3">
            <label class="form-label fw-semibold">Produk <span class="text-danger">*</span></label>
            <select name="product_id" class="gr-form-input" required>
                <option value="">Pilih produk...</option>
                <option value="1">Beras Premium Pulen</option>
                <option value="2">Minyak Goreng 2L</option>
            </select>
        </div>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Minimum Order <span class="text-danger">*</span></label>
                    <input type="number" name="minimum_order" class="gr-form-input" placeholder="500" required>
                </div>
            </div>
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Kapasitas Maks <span class="text-danger">*</span></label>
                    <input type="number" name="capacity" class="gr-form-input" placeholder="2000" required>
                </div>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Area Layanan</label>
            <div class="form-text mt-0 mb-2">Pilih satu atau lebih area</div>
            <div x-data="tomSelectWrapper({maxItems:null,placeholder:'Pilih area...',create:false})">
                <select name="service_areas[]" x-ref="select" multiple class="gr-form-input">
                    <option value="PGH-RT01">PGH-RT01</option>
                    <option value="PGH-RT02">PGH-RT02</option>
                    <option value="PGH-RT03">PGH-RT03</option>
                    <option value="PGH-RT04">PGH-RT04</option>
                    <option value="PGH-RT05">PGH-RT05</option>
                </select>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Biaya Kirim (Rp)</label>
            <input type="number" name="delivery_cost" class="gr-form-input" placeholder="200000">
        </div>

        <div class="mb-3">
            <label class="form-label fw-semibold">Berlaku Sampai <span class="text-danger">*</span></label>
            <input type="text" name="valid_until" class="gr-form-input flatpickr-date" placeholder="Pilih tanggal" required>
        </div>

        <h3 class="fw-semibold mb-3 mt-4" style="font-size:1rem">Tier Harga</h3>
        <div class="row g-3">
            <div class="col-12 col-sm-4">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Min Qty</label>
                    <input type="number" name="tiers[0][min]" class="gr-form-input" placeholder="500">
                </div>
            </div>
            <div class="col-12 col-sm-4">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Maks Qty (0=tak terbatas)</label>
                    <input type="number" name="tiers[0][max]" class="gr-form-input" placeholder="999">
                </div>
            </div>
            <div class="col-12 col-sm-4">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Harga / unit</label>
                    <input type="number" name="tiers[0][price]" class="gr-form-input" placeholder="10500">
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('offers.index') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">
                <i data-lucide="send" style="width:1rem;height:1rem" class="me-1"></i>Submit Offer
            </button>
        </div>
    </form>
</div>
</div>

@push('scripts')
<script>
document.querySelectorAll('.flatpickr-date').forEach(el => flatpickr(el, {minDate:'today', dateFormat:'Y-m-d'}));
</script>
@endpush
@endsection
