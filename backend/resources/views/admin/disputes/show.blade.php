@extends('layouts.app')
@section('title','Detail Dispute')
@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h2 class="h4 mb-1">Dispute #{{ $dispute->id }}</h2>
    </div>
</div>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <div class="card">
            <div class="card-body">
            <h3 class="fw-semibold mb-3" style="font-size:1rem">Detail Dispute</h3>
            <div class="row g-3">
                <div class="col-6">
                    <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Inisiator</p>
                    <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $dispute->initiator->name ?? '-' }}</p>
                </div>
                <div class="col-6">
                    <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Supplier</p>
                    <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $dispute->supplier->name ?? '-' }}</p>
                </div>
                <div class="col-6">
                    <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Total PO</p>
                    <p class="mb-0 fw-semibold" style="font-size:1.1rem;color:var(--primary-500)">
                        Rp{{ number_format($dispute->total_amount,0,',','.') }}
                    </p>
                </div>
                <div class="col-6">
                    <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Status</p>
                    <span class="badge bg-{{ $dispute->status === 'resolved' ? 'success' : ($dispute->status === 'rejected' ? 'danger' : 'warning') }}">{{ ucfirst($dispute->status) }}</span>
                </div>
                <div class="col-12">
                    <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Keterangan</p>
                    <p class="mb-0" style="font-size:.875rem">{{ $dispute->rejected_reason ?? '-' }}</p>
                </div>
            </div>
            </div>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <div class="d-flex flex-column gap-3">
            @if($dispute->status !== 'resolved')
            <div class="card">
                <div class="card-body">
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Resolve Dispute</h3>
                <form method="POST" action="{{ route('admin.disputes.resolve',$dispute->id) }}">
                    @csrf

                    <div class="mb-3">
                        <label class="form-label" for="resolution">Resolusi <span class="text-danger">*</span></label>
                        <select name="resolution" id="resolution" class="form-select" required>
                            <option value="replacement">Replacement (ganti barang)</option>
                            <option value="refund">Refund (kembalikan dana)</option>
                            <option value="none">Tidak ada tindakan</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="refund_amount">Jumlah Refund (Rp)</label>
                        <input type="number" id="refund_amount" name="refund_amount" class="form-control" placeholder="0" min="0">
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="notes">Catatan</label>
                        <textarea id="notes" name="notes" class="form-control" rows="3" placeholder="Penjelasan resolusi..."></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary w-100"><i data-lucide="gavel" class="me-2" style="width:1rem;height:1rem;"></i>Resolve</button>
                </form>
                </div>
            </div>
            @else
            <div class="card">
                <div class="card-body">
                <div class="text-center py-4">
                    <i data-lucide="check-circle" style="width:3rem;height:3rem;color:var(--primary-500);display:block;margin:0 auto .75rem"></i>
                    <h3 class="fw-semibold mb-0" style="font-size:1rem">Dispute Terselesaikan</h3>
                </div>
                </div>
            </div>
            @endif

            <a href="{{ route('admin.disputes.index') }}" class="btn btn-secondary w-100"><i data-lucide="arrow-left" class="me-2" style="width:1rem;height:1rem;"></i>Kembali</a>
        </div>
    </div>
</div>
@endsection
