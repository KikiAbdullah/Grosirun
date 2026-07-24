@extends('layouts.app')
@section('title','Tambah Produk')
@section('content')

<div class="mb-4">
    <h2 class="h4 mb-1">Tambah Produk Baru</h2>
</div>

<div class="card">
    <div class="card-body">
    <form method="POST" action="{{ route('products.store') }}" enctype="multipart/form-data">
        @csrf

        <div class="mb-3">
            <label class="form-label">Nama Produk <span class="text-danger">*</span></label>
            <input type="text" name="name" class="form-control" placeholder="Beras Premium Pulen" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Deskripsi</label>
            <textarea name="description" class="form-control" rows="3"></textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">Base Unit <span class="text-danger">*</span></label>
            <select name="base_unit" class="form-select" required>
                <option value="kg">Kg</option>
                <option value="pcs">Pcs</option>
                <option value="liter">Liter</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Gambar Produk</label>
            <div class="form-text mb-2">JPG/PNG, maks 5MB</div>
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
        </div>

        <h3 class="fw-semibold mb-3 mt-4" style="font-size:1rem">Varian Kemasan</h3>
        <div class="row g-3">
            <div class="col-12 col-sm-4">
                <div class="mb-3">
                    <label class="form-label">Nama</label>
                    <input type="text" name="variants[0][name]" class="form-control" placeholder="5 Kg">
                </div>
            </div>
            <div class="col-12 col-sm-4">
                <div class="mb-3">
                    <label class="form-label">Qty per Paket</label>
                    <input type="number" name="variants[0][qty]" class="form-control" placeholder="5">
                </div>
            </div>
            <div class="col-12 col-sm-4">
                <div class="mb-3">
                    <label class="form-label">Stok Maks</label>
                    <input type="number" name="variants[0][stock]" class="form-control" placeholder="50">
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('products.index') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">Simpan Produk</button>
        </div>
    </form>
    </div>
</div>

@endsection
