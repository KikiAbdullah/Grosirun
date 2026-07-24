@extends('layouts.app')
@section('title','Detail PO')
@section('content')

<div class="mb-4">
    <h2 class="h4 mb-1">PO #{{ $po->uuid }}</h2>
</div>

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <div class="d-flex flex-column gap-4">
            {{-- Detail PO --}}
            <div class="card">
                <div class="card-body">
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Detail Purchase Order</h3>
                <div class="row g-3">
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Inisiator</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $po->initiator->name ?? '-' }}</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Supplier</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $po->supplier->name ?? '-' }}</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Campaign</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $po->campaign->title ?? '-' }}</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Quantity</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $po->total_quantity }}</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Harga / unit</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">Rp{{ number_format($po->unit_price,0,',','.') }}</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Total</p>
                        <p class="mb-0 fw-semibold" style="font-size:1.1rem;color:var(--primary-500)">Rp{{ number_format($po->total_amount,0,',','.') }}</p>
                    </div>
                </div>
                </div>
            </div>

            {{-- Upload Dokumen --}}
            <div class="card">
                <div class="card-body">
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Upload Dokumen</h3>
                <div x-data="filepondUploader({
                    processUrl:'{{ route('purchase-orders.upload-document',$po->uuid) }}',
                    multiple:true,
                    label:'Seret invoice/surat jalan ke sini atau <span class=\'filepond--label-action\'>pilih file</span>'
                })">
                    <input type="file" x-ref="pond" name="documents[]" multiple>
                </div>
                </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <div class="card">
            <div class="card-body">
            <div class="d-flex align-items-center gap-2 mb-3">
                <i data-lucide="info" style="width:1.25rem;height:1.25rem;color:var(--info-500)"></i>
                <span class="fw-semibold" style="font-size:.95rem">Status</span>
            </div>
            <span class="badge bg-secondary">{{ $po->status }}</span>

            <div class="d-flex flex-column gap-2 mt-4">
                @if($po->status === 'submitted')
                    <form method="POST" action="{{ route('purchase-orders.accept',$po->uuid) }}">
                        @csrf
                        <button type="submit" class="btn btn-primary w-100">Accept PO</button>
                    </form>
                    <form method="POST" action="{{ route('purchase-orders.reject',$po->uuid) }}">
                        @csrf
                        <input type="hidden" name="reason" value="Tidak sesuai">
                        <button type="submit" class="btn btn-danger w-100"
                            onclick="return confirm('Yakin tolak PO?')">Reject PO</button>
                    </form>
                @elseif($po->status === 'accepted')
                    <form method="POST" action="{{ route('purchase-orders.confirm-payment',$po->uuid) }}">
                        @csrf
                        <button type="submit" class="btn btn-primary w-100">Konfirmasi Pembayaran</button>
                    </form>
                @elseif($po->status === 'paid')
                    <form method="POST" action="{{ route('purchase-orders.update-status',$po->uuid) }}">
                        @csrf
                        <input type="hidden" name="status" value="processing">
                        <button type="submit" class="btn btn-primary w-100">Proses</button>
                    </form>
                @elseif($po->status === 'processing')
                    <form method="POST" action="{{ route('purchase-orders.update-status',$po->uuid) }}">
                        @csrf
                        <input type="hidden" name="status" value="shipped">
                        <button type="submit" class="btn btn-primary w-100">Tandai Dikirim</button>
                    </form>
                @endif
            </div>
            </div>
        </div>
    </div>
</div>
@endsection
