@extends('layouts.app')
@section('title','Buat PO')
@section('content')

<x-ui.page-header title="Buat Purchase Order" subtitle="Kirim PO ke supplier berdasarkan campaign." />

<x-ui.card>
    <form method="POST" action="{{ route('purchase-orders.store') }}">
        @csrf

        <x-ui.form-group label="Campaign" name="campaign_id" required>
            <select name="campaign_id" class="gr-form-input" required>
                <option value="">Pilih campaign...</option>
                <option value="1">Beras Premium Pulen — 500 Kg</option>
            </select>
        </x-ui.form-group>

        <x-ui.form-group label="Supplier" name="supplier_id" required>
            <select name="supplier_id" class="gr-form-input" required>
                <option value="">Pilih supplier...</option>
                <option value="1">CV Makmur Jaya</option>
                <option value="2">UD Sumber Rejeki</option>
            </select>
        </x-ui.form-group>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Quantity" name="quantity" required>
                    <input type="number" name="quantity" class="gr-form-input" placeholder="500" required>
                </x-ui.form-group>
            </div>
            <div class="col-12 col-sm-6">
                <x-ui.form-group label="Harga / unit" name="unit_price" required>
                    <input type="number" name="unit_price" class="gr-form-input" placeholder="10500" required>
                </x-ui.form-group>
            </div>
        </div>

        <x-ui.form-group label="Catatan" name="notes">
            <textarea name="notes" class="gr-form-input" rows="2" placeholder="Catatan tambahan..."></textarea>
        </x-ui.form-group>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <x-ui.button variant="secondary" href="{{ route('purchase-orders.index') }}">Batal</x-ui.button>
            <x-ui.button type="submit" variant="primary" icon="send">Kirim PO</x-ui.button>
        </div>
    </form>
</x-ui.card>
@endsection
