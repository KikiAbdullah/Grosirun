@extends('layouts.app')
@section('title','Detail Pesanan')
@section('content')

<x-ui.page-header title="Beras Premium Pulen" subtitle="Pesanan #{{ $uuid }}" />

<div class="row g-4">
    <div class="col-12 col-lg-8">
        <div class="d-flex flex-column gap-4">
            {{-- Detail Pesanan --}}
            <x-ui.card>
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Detail Pesanan</h3>
                <div class="row g-3">
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Varian</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">5 Kg</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Quantity</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">1</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Metode</p>
                        <p class="mb-0 fw-medium" style="font-size:.875rem">CASH</p>
                    </div>
                    <div class="col-6">
                        <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">Total</p>
                        <p class="mb-0 fw-semibold" style="font-size:1.1rem;color:var(--primary-500)">Rp60.000</p>
                    </div>
                </div>
            </x-ui.card>

            {{-- Upload Bukti --}}
            <x-ui.card>
                <h3 class="fw-semibold mb-3" style="font-size:1rem">Upload Bukti Pembayaran</h3>
                <div x-data="imagePreview()">
                    <input type="file" accept="image/*" @change="handleFile($event)" class="d-none" id="proof-input">
                    <label for="proof-input" class="gr-upload-area">
                        <template x-if="!preview">
                            <div class="text-center">
                                <i data-lucide="upload-cloud" style="width:2.5rem;height:2.5rem;color:var(--text-disabled);display:block;margin:0 auto .5rem"></i>
                                <p class="mb-1" style="font-size:.875rem;color:var(--text-secondary)">Klik atau seret gambar bukti transfer</p>
                                <p class="mb-0" style="font-size:.75rem;color:var(--text-disabled)">JPG/PNG, maks 2MB</p>
                            </div>
                        </template>
                        <template x-if="preview">
                            <img :src="preview" style="max-height:12rem;border-radius:.75rem">
                        </template>
                    </label>
                    <p x-show="error" x-text="error" class="gr-form-error mt-2"></p>
                    <p x-show="fileName" class="mb-0 mt-2" style="font-size:.8rem;color:var(--text-secondary)">
                        <span x-text="fileName"></span> • <span x-text="fileSize"></span>
                    </p>
                    <div x-show="preview" class="d-flex gap-2 mt-3">
                        <x-ui.button variant="primary" icon="upload" class="flex-grow-1">Upload Bukti</x-ui.button>
                        <x-ui.button variant="ghost" @click="clear()" icon="x">Hapus</x-ui.button>
                    </div>
                </div>
            </x-ui.card>
        </div>
    </div>

    <div class="col-12 col-lg-4">
        <x-ui.card>
            <div class="d-flex align-items-center gap-2 mb-2">
                <i data-lucide="check-circle" style="width:1.25rem;height:1.25rem;color:var(--primary-500)"></i>
                <span class="fw-semibold" style="font-size:.95rem">Status</span>
            </div>
            <x-ui.status-badge status="paid" />
        </x-ui.card>
    </div>
</div>

@endsection
