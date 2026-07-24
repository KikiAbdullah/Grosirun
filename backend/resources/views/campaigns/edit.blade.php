@extends('layouts.app')
@section('title','Edit Campaign')
@section('content')

<x-ui.page-header title="Edit Campaign" />

<x-ui.card>
    <form method="POST" action="{{ route('campaigns.update',$uuid) }}">
        @csrf @method('PUT')

        <x-ui.form-group label="Judul" name="title" required>
            <input type="text" name="title" class="gr-form-input" value="Beras Premium Pulen" required>
        </x-ui.form-group>

        <x-ui.form-group label="Target" name="target_quantity">
            <input type="number" name="target_quantity" class="gr-form-input" value="500">
        </x-ui.form-group>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('campaigns.manage') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="save">Simpan</x-ui.button>
        </div>
    </form>
</x-ui.card>
@endsection
