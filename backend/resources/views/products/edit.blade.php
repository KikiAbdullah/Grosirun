@extends('layouts.app')
@section('title','Edit Produk')
@section('content')

<div class="mb-4">
    <h2 class="h4 mb-1">Edit Produk</h2>
</div>

<div class="card">
    <div class="card-body">
    <form method="POST" action="{{ route('products.update',$id) }}">
        @csrf @method('PUT')

        <div class="mb-3">
            <label class="form-label">Nama Produk <span class="text-danger">*</span></label>
            <input type="text" name="name" class="form-control" value="Beras Premium Pulen" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Deskripsi</label>
            <textarea name="description" class="form-control" rows="3">Beras premium kualitas terbaik</textarea>
        </div>

        <div class="mb-3">
            <label class="form-label">Base Unit</label>
            <select name="base_unit" class="form-select">
                <option value="kg" selected>Kg</option>
            </select>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('products.index') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">Simpan</button>
        </div>
    </form>
    </div>
</div>

@endsection
