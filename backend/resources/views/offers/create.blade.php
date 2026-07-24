@extends('layouts.app')
@section('title','Buat Offer')
@section('content')

<x-ui.page-header title="Buat Offer Baru" subtitle="Tentukan harga tier dan area layanan." />

<x-ui.card>
    <form method="POST" action="{{ route('offers.store') }}">
        @csrf

        <x-ui.form-group label="Produk" name="product_id" required>
            <select name="product_id" class="gr-form-input" required>
                <option value="">Pilih produk...</option>
                <option value="1">Beras Premium Pulen</option>
                <option value="2">Minyak Goreng 2L</option>
            </select>
        </x-ui.form-group>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Minimum Order" name="minimum_order" required>
                    <input type="number" name="minimum_order" class="gr-form-input" placeholder="500" required>
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Kapasitas Maks" name="capacity" required>
                    <input type="number" name="capacity" class="gr-form-input" placeholder="2000" required>
                </x-ui.form-group>
            </div>
        </div>

        <x-ui.form-group label="Area Layanan" name="service_areas[]" hint="Pilih satu atau lebih area">
            <div x-data="tomSelectWrapper({maxItems:null,placeholder:'Pilih area...',create:false})">
                <select name="service_areas[]" x-ref="select" multiple class="gr-form-input">
                    <option value="PGH-RT01">PGH-RT01</option>
                    <option value="PGH-RT02">PGH-RT02</option>
                    <option value="PGH-RT03">PGH-RT03</option>
                    <option value="PGH-RT04">PGH-RT04</option>
                    <option value="PGH-RT05">PGH-RT05</option>
                </select>
            </div>
        </x-ui.form-group>

        <x-ui.form-group label="Biaya Kirim (Rp)" name="delivery_cost">
            <input type="number" name="delivery_cost" class="gr-form-input" placeholder="200000">
        </x-ui.form-group>

        <x-ui.form-group label="Berlaku Sampai" name="valid_until" required>
            <input type="text" name="valid_until" class="gr-form-input flatpickr-date" placeholder="Pilih tanggal" required>
        </x-ui.form-group>

        <h3 class="fw-semibold mb-3 mt-4" style="font-size:1rem">Tier Harga</h3>
        <div class="row g-3">
            <div class="col-12 col-sm-4">
                <x-ui.form-group label="Min Qty" name="tiers[0][min]">
                    <input type="number" name="tiers[0][min]" class="gr-form-input" placeholder="500">
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-4">
                <x-ui.form-group label="Maks Qty (0=tak terbatas)" name="tiers[0][max]">
                    <input type="number" name="tiers[0][max]" class="gr-form-input" placeholder="999">
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-4">
                <x-ui.form-group label="Harga / unit" name="tiers[0][price]">
                    <input type="number" name="tiers[0][price]" class="gr-form-input" placeholder="10500">
                </x-ui.form-group>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('offers.index') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="send">Submit Offer</x-ui.button>
        </div>
    </form>
</x-ui.card>

@push('scripts')
<script>
document.querySelectorAll('.flatpickr-date').forEach(el => flatpickr(el, {minDate:'today', dateFormat:'Y-m-d'}));
</script>
@endpush
@endsection
