@extends('layouts.app')
@section('title','Edit Produk')
@section('content')

<x-ui.page-header title="Edit Produk" />

<x-ui.card>
    <form method="POST" action="{{ route('products.update',$id) }}">
        @csrf @method('PUT')

        <x-ui.form-group label="Nama Produk" name="name" required>
            <input type="text" name="name" class="gr-form-input" value="Beras Premium Pulen" required>
        </x-ui.form-group>

        <x-ui.form-group label="Deskripsi" name="description">
            <textarea name="description" class="gr-form-input" rows="3">Beras premium kualitas terbaik</textarea>
        </x-ui.form-group>

        <x-ui.form-group label="Base Unit" name="base_unit">
            <select name="base_unit" class="gr-form-input">
                <option value="kg" selected>Kg</option>
            </select>
        </x-ui.form-group>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('products.index') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="save">Simpan</x-ui.button>
        </div>
    </form>
</x-ui.card>

@endsection
