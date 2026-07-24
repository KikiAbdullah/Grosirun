@extends('layouts.app')
@section('title','Detail PO')
@section('content')

<x-ui.page-header title="PO #{{ $po->uuid }}" />

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <div class="d-flex flex-column gap-4">
            {{-- Detail PO --}}
            <x-ui.card>
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
            </x-ui.card>

            {{-- Upload Dokumen --}}
            <x-ui.card>
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Upload Dokumen</h3>
                <div x-data="filepondUploader({
                    processUrl:'{{ route('purchase-orders.upload-document',$po->uuid) }}',
                    multiple:true,
                    label:'Seret invoice/surat jalan ke sini atau <span class=\'filepond--label-action\'>pilih file</span>'
                })">
                    <input type="file" x-ref="pond" name="documents[]" multiple>
                </div>
            </x-ui.card>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <x-ui.card>
            <div class="d-flex align-items-center gap-2 mb-3">
                <i data-lucide="info" style="width:1.25rem;height:1.25rem;color:var(--info-500)"></i>
                <span class="fw-semibold" style="font-size:.95rem">Status</span>
            </div>
            <x-ui.status-badge :status="$po->status" />

            <div class="d-flex flex-column gap-2 mt-4">
                @if($po->status === 'submitted')
                    <form method="POST" action="{{ route('purchase-orders.accept',$po->uuid) }}">
                        @csrf
                        <x-ui.button type="submit" variant="primary" icon="check" class="w-100">Accept PO</x-ui.button>
                    </form>
                    <form method="POST" action="{{ route('purchase-orders.reject',$po->uuid) }}">
                        @csrf
                        <input type="hidden" name="reason" value="Tidak sesuai">
                        <x-ui.button type="submit" variant="danger" icon="x" class="w-100"
                            onclick="return confirm('Yakin tolak PO?')">Reject PO</x-ui.button>
                    </form>
                @elseif($po->status === 'accepted')
                    <form method="POST" action="{{ route('purchase-orders.confirm-payment',$po->uuid) }}">
                        @csrf
                        <x-ui.button type="submit" variant="primary" icon="banknote" class="w-100">Konfirmasi Pembayaran</x-ui.button>
                    </form>
                @elseif($po->status === 'paid')
                    <form method="POST" action="{{ route('purchase-orders.update-status',$po->uuid) }}">
                        @csrf
                        <input type="hidden" name="status" value="processing">
                        <x-ui.button type="submit" variant="primary" class="w-100">Proses</x-ui.button>
                    </form>
                @elseif($po->status === 'processing')
                    <form method="POST" action="{{ route('purchase-orders.update-status',$po->uuid) }}">
                        @csrf
                        <input type="hidden" name="status" value="shipped">
                        <x-ui.button type="submit" variant="primary" icon="truck" class="w-100">Tandai Dikirim</x-ui.button>
                    </form>
                @endif
            </div>
        </x-ui.card>
    </div>
</div>
@endsection
