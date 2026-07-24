@extends('layouts.app')
@section('title','Edit Offer')
@section('content')

<x-ui.page-header title="Edit Offer" />

<x-ui.card>
    <form method="POST" action="{{ route('offers.update',$id) }}">
        @csrf @method('PUT')

        <x-ui.form-group label="Produk" name="product_id">
            <select name="product_id" class="gr-form-input">
                <option value="1" selected>Beras Premium Pulen</option>
            </select>
        </x-ui.form-group>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Min Order" name="minimum_order">
                    <input type="number" name="minimum_order" class="gr-form-input" value="500">
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Kapasitas" name="capacity">
                    <input type="number" name="capacity" class="gr-form-input" value="2000">
                </x-ui.form-group>
            </div>
        </div>

        <x-ui.form-group label="Area Layanan" name="service_areas[]">
            <div x-data="tomSelectWrapper({maxItems:null})">
                <select name="service_areas[]" x-ref="select" multiple class="gr-form-input">
                    <option value="PGH-RT03" selected>PGH-RT03</option>
                    <option value="PGH-RT05" selected>PGH-RT05</option>
                </select>
            </div>
        </x-ui.form-group>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('offers.index') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="save">Simpan</x-ui.button>
        </div>
    </form>
</x-ui.card>
@endsection
