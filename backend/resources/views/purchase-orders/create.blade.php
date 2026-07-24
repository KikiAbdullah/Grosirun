@extends('layouts.app')
@section('title','Buat PO')
@section('content')

<div class="mb-4">
    <h2 class="h4 mb-1">Buat Purchase Order</h2>
    <p class="text-muted mb-0">Kirim PO ke supplier berdasarkan campaign.</p>
</div>

<div class="card">
    <div class="card-body">
    <form method="POST" action="{{ route('purchase-orders.store') }}">
        @csrf

        <div class="mb-3">
            <label class="form-label">Campaign <span class="text-danger">*</span></label>
            <select name="campaign_id" class="form-select" required>
                <option value="">Pilih campaign...</option>
                <option value="1">Beras Premium Pulen — 500 Kg</option>
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Supplier <span class="text-danger">*</span></label>
            <select name="supplier_id" class="form-select" required>
                <option value="">Pilih supplier...</option>
                <option value="1">CV Makmur Jaya</option>
                <option value="2">UD Sumber Rejeki</option>
            </select>
        </div>

        <div class="row g-3">
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label">Quantity <span class="text-danger">*</span></label>
                    <input type="number" name="quantity" class="form-control" placeholder="500" required>
                </div>
            </div>
            <div class="col-12 col-sm-6">
                <div class="mb-3">
                    <label class="form-label">Harga / unit <span class="text-danger">*</span></label>
                    <input type="number" name="unit_price" class="form-control" placeholder="10500" required>
                </div>
            </div>
        </div>

        <div class="mb-3">
            <label class="form-label">Catatan</label>
            <textarea name="notes" class="form-control" rows="2" placeholder="Catatan tambahan..."></textarea>
        </div>

        <div class="d-flex justify-content-end gap-2 mt-4">
            <a href="{{ route('purchase-orders.index') }}" class="btn btn-secondary">Batal</a>
            <button type="submit" class="btn btn-primary">Kirim PO</button>
        </div>
    </form>
    </div>
</div>
@endsection
