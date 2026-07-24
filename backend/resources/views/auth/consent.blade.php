@extends('layouts.app')
@section('title','Persetujuan Data')
@section('content')

<div class="mx-auto" style="max-width:40rem">
    <x-ui.card padding="lg">
        <div class="d-flex align-items-center gap-3 mb-4">
            <div class="d-flex align-items-center justify-content-center rounded-3 flex-shrink-0"
                 style="width:3rem;height:3rem;background:var(--info-50)">
                <i data-lucide="shield-check" style="width:1.5rem;height:1.5rem;color:var(--info-500)"></i>
            </div>
            <div>
                <h1 class="fw-bold mb-0" style="font-size:1.25rem;color:var(--text-primary)">Persetujuan Data Pribadi</h1>
                <p class="mb-0" style="font-size:.875rem;color:var(--text-secondary)">Sesuai UU PDP No. 27 Tahun 2022</p>
            </div>
        </div>

        <div class="mb-4" style="font-size:.875rem;color:var(--text-secondary)">
            <p class="mb-2">Dengan melanjutkan, Anda menyetujui:</p>
            <ul class="ps-4" style="line-height:1.8">
                <li>Nomor WhatsApp digunakan untuk <strong>login &amp; transaksi</strong></li>
                <li>Data transaksi disimpan untuk <strong>audit trail</strong></li>
                <li>Data <strong>tidak dijual</strong> ke pihak ketiga</li>
                <li>Bukti penyimpanan retensi <strong>90 hari</strong></li>
                <li>Berhak <strong>menghapus akun</strong> kapan saja</li>
            </ul>
        </div>

        <form method="POST" action="{{ route('consent.accept') }}">
            @csrf
            <label class="d-flex align-items-start gap-2 mb-4" style="cursor:pointer">
                <input type="checkbox" name="agree" required class="mt-1 form-check-input flex-shrink-0"
                       style="accent-color:var(--primary-500)">
                <span style="font-size:.875rem">Saya <strong>setuju</strong> dengan kebijakan privasi di atas.</span>
            </label>
            <x-ui.button type="submit" variant="primary" icon="check" class="w-100">Lanjutkan</x-ui.button>
        </form>
    </x-ui.card>
</div>

@endsection
