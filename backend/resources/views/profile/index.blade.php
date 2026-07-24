@extends('layouts.app')
@section('title','Profil')
@section('content')

<div class="mx-auto" style="max-width:40rem">
    <div class="card p-4"><div class="card-body">
        {{-- Avatar & Info --}}
        <div class="d-flex align-items-center gap-4 mb-4">
            <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold flex-shrink-0"
                 style="width:5rem;height:5rem;background:var(--primary-500);font-size:1.75rem">BS</div>
            <div>
                <h2 class="fw-bold mb-1" style="font-size:1.25rem">Bu Siti Rahayu</h2>
                <p class="mb-0" style="font-size:.875rem;color:var(--text-secondary)">081234567890</p>
                <p class="mb-0" style="font-size:.8rem;color:var(--text-secondary)">PGH-RT03 Permata Hijau</p>
            </div>
        </div>

        <div class="d-flex gap-2 mb-4">
            <span class="gr-badge gr-badge-success">
                <i data-lucide="check-circle" style="width:.75rem;height:.75rem"></i>Consent
            </span>
            <span class="gr-badge gr-badge-success">
                <i data-lucide="check-circle" style="width:.75rem;height:.75rem"></i>ToS
            </span>
            <span class="gr-badge gr-badge-info">Buyer</span>
        </div>

        <hr style="border-color:var(--surface-200)">

        {{-- Role Switch --}}
        <h3 class="fw-semibold mb-3" style="font-size:1rem">Ganti Role Aktif</h3>
        <form method="POST" action="{{ route('profile.switch-role') }}" class="mb-4">
            @csrf
            <div class="row g-2">
                @foreach(['buyer'=>'Buyer','initiator'=>'Inisiator','seller'=>'Seller','admin'=>'Admin'] as $role=>$label)
                <div class="col-6 col-sm-3">
                    <button type="submit" name="role" value="{{ $role }}"
                            class="w-100 py-3 rounded-3 fw-semibold text-center border"
                            style="font-size:.875rem;cursor:pointer;transition:all .15s;
                                   {{ (session('active_role','buyer') === $role)
                                        ? 'background:var(--primary-50);border-color:var(--primary-500);color:var(--primary-600)'
                                        : 'background:transparent;border-color:var(--surface-200);color:var(--text-primary)' }}">
                        {{ $label }}
                    </button>
                </div>
                @endforeach
            </div>
        </form>

        <hr style="border-color:var(--surface-200)">

        {{-- FAQ --}}
        <h3 class="fw-semibold mb-3" style="font-size:1rem">FAQ</h3>
        <div x-data="{open:null}" class="d-flex flex-column gap-2">
            @foreach([
                ['q'=>'Bagaimana cara ikut patungan?','a'=>'Buka menu Campaign, pilih campaign aktif, pilih varian, lalu checkout.'],
                ['q'=>'Bagaimana jika PO batal?','a'=>'Initiator wajib refund 100% dalam 2x24 jam.'],
                ['q'=>'Apakah data saya aman?','a'=>'Ya, sesuai UU PDP. Data tidak dijual dan bisa dihapus.'],
            ] as $i => $faq)
            <div class="border rounded-3 overflow-hidden" style="border-color:var(--surface-200)">
                <button @click="open==={{ $i }} ? open=null : open={{ $i }}"
                        class="w-100 d-flex align-items-center justify-content-between p-3 border-0 bg-transparent text-start fw-semibold"
                        style="font-size:.875rem;cursor:pointer"
                        :style="open==={{ $i }} ? 'background:var(--surface-50)' : ''">
                    <span>{{ $faq['q'] }}</span>
                    <i data-lucide="chevron-down" style="width:1rem;height:1rem;transition:transform .2s;flex-shrink:0"
                       :style="open==={{ $i }} ? 'transform:rotate(180deg)' : ''"></i>
                </button>
                <div x-show="open==={{ $i }}" x-collapse>
                    <div class="px-3 pb-3" style="font-size:.875rem;color:var(--text-secondary)">{{ $faq['a'] }}</div>
                </div>
            </div>
            @endforeach
        </div>

        <hr class="mt-4" style="border-color:var(--surface-200)">

        {{-- Logout --}}
        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit" class="btn btn-danger w-100"><i data-lucide="log-out" style="width:1rem;height:1rem" class="me-2"></i>Keluar</button>
        </form>
    </div></div>

    <p class="text-center mt-3" style="font-size:.75rem;color:var(--text-disabled)">Grosirun v1.0.0</p>
</div>
@endsection
