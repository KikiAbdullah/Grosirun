@extends('layouts.app')
@section('title','Buat Campaign')
@section('content')

<x-ui.page-header title="Buat Campaign Baru" subtitle="Isi detail campaign patungan." />

<x-ui.card>
    <form method="POST" action="{{ route('campaigns.store') }}">
        @csrf

        <x-ui.form-group label="Judul Campaign" name="title" required>
            <input type="text" name="title" class="gr-form-input" placeholder="Beras Premium Pulen" required>
        </x-ui.form-group>

        <x-ui.form-group label="Deskripsi" name="description">
            <textarea name="description" class="gr-form-input" rows="3" placeholder="Deskripsi campaign..."></textarea>
        </x-ui.form-group>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Target Quantity" name="target_quantity" required>
                    <input type="number" name="target_quantity" class="gr-form-input" placeholder="1000" required>
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Satuan" name="unit" required>
                    <select name="unit" class="gr-form-input" required>
                        <option value="kg">Kg</option>
                        <option value="pcs">Pcs</option>
                        <option value="liter">Liter</option>
                    </select>
                </x-ui.form-group>
            </div>
        </div>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Harga Buyer / unit" name="buyer_unit_price" required>
                    <input type="number" name="buyer_unit_price" class="gr-form-input" placeholder="12000" required>
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Tenggat (hari)" name="deadline_days" required>
                    <input type="number" name="deadline_days" class="gr-form-input" placeholder="2" min="1" required>
                </x-ui.form-group>
            </div>
        </div>

        <x-ui.form-group label="Lokasi Distribusi" name="location" required>
            <input type="text" name="location" class="gr-form-input" placeholder="Rumah Pak RT Jl Mawar 12" required>
        </x-ui.form-group>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('campaigns.index') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="send">Publikasikan</x-ui.button>
        </div>
    </form>
</x-ui.card>
@endsection
