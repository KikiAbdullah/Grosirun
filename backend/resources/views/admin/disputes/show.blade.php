@extends('layouts.app')
@section('title','Detail Dispute')
@section('content')

<x-ui.page-header title="Dispute #{{ $dispute->id }}" />

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <x-ui.card>
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
                    <x-ui.status-badge :status="$dispute->status" />
                </div>
                <div class="col-12">
                    <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Keterangan</p>
                    <p class="mb-0" style="font-size:.875rem">{{ $dispute->rejected_reason ?? '-' }}</p>
                </div>
            </div>
        </x-ui.card>
    </div>

    <div class="col-12 col-lg-4">
        <div class="d-flex flex-column gap-3">
            @if($dispute->status !== 'resolved')
            <x-ui.card>
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Resolve Dispute</h3>
                <form method="POST" action="{{ route('admin.disputes.resolve',$dispute->id) }}">
                    @csrf

                    <x-ui.form-group label="Resolusi" name="resolution" required>
                        <select name="resolution" class="gr-form-input" required>
                            <option value="replacement">Replacement (ganti barang)</option>
                            <option value="refund">Refund (kembalikan dana)</option>
                            <option value="none">Tidak ada tindakan</option>
                        </select>
                    </x-ui.form-group>

                    <x-ui.form-group label="Jumlah Refund (Rp)" name="refund_amount">
                        <input type="number" name="refund_amount" class="gr-form-input" placeholder="0" min="0">
                    </x-ui.form-group>

                    <x-ui.form-group label="Catatan" name="notes">
                        <textarea name="notes" class="gr-form-input" rows="3" placeholder="Penjelasan resolusi..."></textarea>
                    </x-ui.form-group>

                    <x-ui.button type="submit" variant="primary" icon="gavel" class="w-100">Resolve</x-ui.button>
                </form>
            </x-ui.card>
            @else
            <x-ui.card>
                <div class="text-center py-4">
                    <i data-lucide="check-circle" style="width:3rem;height:3rem;color:var(--primary-500);display:block;margin:0 auto .75rem"></i>
                    <h3 class="fw-semibold mb-0" style="font-size:1rem">Dispute Terselesaikan</h3>
                </div>
            </x-ui.card>
            @endif

            <x-ui.button variant="secondary" href="{{ route('admin.disputes.index') }}" icon="arrow-left" class="w-100">
                Kembali
            </x-ui.button>
        </div>
    </div>
</div>
@endsection
