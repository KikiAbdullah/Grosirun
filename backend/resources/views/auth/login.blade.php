<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Masuk — Grosirun</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="{{ asset('css/app.css') }}">
</head>
<body style="background:var(--surface-50);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:1rem">

<div style="width:100%;max-width:26rem">
    {{-- Logo --}}
    <div class="text-center mb-4">
        <div class="d-flex align-items-center justify-content-center rounded-3 text-white mx-auto mb-3"
             style="width:4rem;height:4rem;background:var(--primary-500)">
            <i data-lucide="shopping-bag" style="width:2.25rem;height:2.25rem"></i>
        </div>
        <h1 class="fw-black mb-1" style="font-size:1.75rem;color:var(--text-primary)">Grosirun</h1>
        <p style="font-size:.875rem;color:var(--text-secondary)">Yuk, Grosirun Bareng!</p>
    </div>

    {{-- Card --}}
    <div class="gr-card p-4">
        <h2 class="fw-bold mb-1" style="font-size:1.1rem;color:var(--text-primary)">Masuk ke Akun</h2>
        <p class="mb-4" style="font-size:.875rem;color:var(--text-secondary)">Gunakan nomor WhatsApp untuk login.</p>

        <form method="POST" action="{{ route('login.submit') }}">
            @csrf
            <x-ui.form-group label="Nomor WhatsApp" name="phone_number" required>
                <div class="position-relative">
                    <span class="position-absolute" style="left:1rem;top:50%;transform:translateY(-50%);color:var(--text-secondary);font-size:.875rem">+62</span>
                    <input type="tel" name="phone_number"
                           class="gr-form-input @error('phone_number') gr-form-input-error @enderror"
                           style="padding-left:3rem"
                           placeholder="81234567890" required>
                </div>
            </x-ui.form-group>

            <div class="mb-4">
                <label class="d-flex align-items-start gap-2" style="cursor:pointer">
                    <input type="checkbox" name="consent" required class="mt-1 form-check-input flex-shrink-0"
                           style="accent-color:var(--primary-500)">
                    <span style="font-size:.875rem;color:var(--text-secondary)">
                        Saya setuju data WA disimpan sesuai <a href="#" style="color:var(--primary-600);font-weight:600">UU PDP</a>.
                    </span>
                </label>
            </div>

            <x-ui.button type="submit" variant="primary" icon="send" class="w-100">Kirim Kode OTP</x-ui.button>
        </form>

        {{-- Divider --}}
        <div class="position-relative my-4">
            <hr style="border-color:var(--surface-200)">
            <span class="position-absolute top-50 start-50 translate-middle px-3 bg-white"
                  style="font-size:.75rem;color:var(--text-disabled)">atau</span>
        </div>

        {{-- Demo Login --}}
        <p class="mb-2 text-center" style="font-size:.875rem;color:var(--text-secondary)">Demo login:</p>
        <div class="row g-2">
            @foreach(['buyer'=>'Buyer','initiator'=>'Inisiator','seller'=>'Seller','admin'=>'Admin'] as $role=>$label)
            <div class="col-6">
                <form method="POST" action="{{ route('login.submit') }}">
                    @csrf
                    <input type="hidden" name="phone_number" value="081234567890">
                    <input type="hidden" name="consent" value="1">
                    <input type="hidden" name="demo_role" value="{{ $role }}">
                    <button type="submit" class="w-100 gr-btn gr-btn-secondary gr-btn-sm">{{ $label }}</button>
                </form>
            </div>
            @endforeach
        </div>
    </div>

    <p class="text-center mt-3" style="font-size:.75rem;color:var(--text-disabled)">&copy; 2026 Grosirun</p>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
<script>document.addEventListener('DOMContentLoaded', () => lucide.createIcons())</script>
</body>
</html>
