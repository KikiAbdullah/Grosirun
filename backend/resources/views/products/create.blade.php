@extends('layouts.app')
@section('title','Tambah Produk')
@section('content')

<x-ui.page-header title="Tambah Produk Baru" />

<x-ui.card>
    <form method="POST" action="{{ route('products.store') }}" enctype="multipart/form-data">
        @csrf

        <x-ui.form-group label="Nama Produk" name="name" required>
            <input type="text" name="name" class="gr-form-input" placeholder="Beras Premium Pulen" required>
        </x-ui.form-group>

        <x-ui.form-group label="Deskripsi" name="description">
            <textarea name="description" class="gr-form-input" rows="3"></textarea>
        </x-ui.form-group>

        <x-ui.form-group label="Base Unit" name="base_unit" required>
            <select name="base_unit" class="gr-form-input" required>
                <option value="kg">Kg</option>
                <option value="pcs">Pcs</option>
                <option value="liter">Liter</option>
            </select>
        </x-ui.form-group>

        <x-ui.form-group label="Gambar Produk" name="image" hint="JPG/PNG, maks 5MB">
            <div x-data="imagePreview()">
                <input type="file" name="image" accept="image/*" @change="handleFile($event)" class="d-none" id="img-input">
                <label for="img-input" class="gr-upload-area">
                    <template x-if="!preview">
                        <div class="text-center">
                            <i data-lucide="upload-cloud" style="width:2.5rem;height:2.5rem;color:var(--text-disabled);display:block;margin:0 auto .5rem"></i>
                            <p class="mb-0" style="font-size:.875rem;color:var(--text-secondary)">Klik untuk upload gambar</p>
                        </div>
                    </template>
                    <template x-if="preview">
                        <img :src="preview" style="max-height:12rem;border-radius:.75rem">
                    </template>
                </label>
                <p x-show="error" x-text="error" class="gr-form-error mt-2"></p>
            </div>
        </x-ui.form-group>

        <h3 class="fw-semibold mb-3 mt-4" style="font-size:1rem">Varian Kemasan</h3>
        <div class="row g-3">
            <div class="col-12 col-sm-4">
                <x-ui.form-group label="Nama" name="variants[0][name]">
                    <input type="text" name="variants[0][name]" class="gr-form-input" placeholder="5 Kg">
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-4">
                <x-ui.form-group label="Qty per Paket" name="variants[0][qty]">
                    <input type="number" name="variants[0][qty]" class="gr-form-input" placeholder="5">
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-4">
                <x-ui.form-group label="Stok Maks" name="variants[0][stock]">
                    <input type="number" name="variants[0][stock]" class="gr-form-input" placeholder="50">
                </x-ui.form-group>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('products.index') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="save">Simpan Produk</x-ui.button>
        </div>
    </form>
</x-ui.card>

@endsection
