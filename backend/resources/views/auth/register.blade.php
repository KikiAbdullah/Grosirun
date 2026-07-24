<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Daftar — Grosirun</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
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
        <h1 class="fw-black mb-0" style="font-size:1.75rem;color:var(--text-primary)">Buat Akun Baru</h1>
    </div>

    {{-- Card --}}
    <div class="gr-card p-4">
        <form method="POST" action="{{ route('register.submit') }}">
            @csrf
            <div class="mb-3">
                <label class="form-label">Nama Lengkap <span class="text-danger">*</span></label>
                <input type="text" name="name"
                       class="gr-form-input @error('name') gr-form-input-error @enderror"
                       placeholder="Siti Rahayu" required value="{{ old('name') }}">
            </div>

            <div class="mb-3">
                <label class="form-label">Nomor WhatsApp <span class="text-danger">*</span></label>
                <div class="position-relative">
                    <span class="position-absolute" style="left:1rem;top:50%;transform:translateY(-50%);color:var(--text-secondary);font-size:.875rem">+62</span>
                    <input type="tel" name="phone_number"
                           class="gr-form-input @error('phone_number') gr-form-input-error @enderror"
                           style="padding-left:3rem"
                           placeholder="81234567890" required>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label">Cluster / RT</label>
                <input type="text" name="cluster_code" class="gr-form-input"
                       value="{{ old('cluster_code','PGH-RT03') }}">
                <div class="form-text" style="font-size:.75rem">Kode cluster tempat tinggal</div>
            </div>

            <div class="mb-4">
                <label class="d-flex align-items-start gap-2" style="cursor:pointer">
                    <input type="checkbox" name="consent" required class="mt-1 form-check-input flex-shrink-0"
                           style="accent-color:var(--primary-500)">
                    <span style="font-size:.875rem;color:var(--text-secondary)">
                        Saya setuju <a href="#" style="color:var(--primary-600);font-weight:600">Syarat Layanan</a>
                        dan <a href="#" style="color:var(--primary-600);font-weight:600">Kebijakan Privasi</a>.
                    </span>
                </label>
            </div>

            <button type="submit" class="btn btn-primary w-100"><i data-lucide="user-plus" style="width:1rem;height:1rem" class="me-2"></i>Daftar Sekarang</button>
        </form>

        <p class="text-center mt-3 mb-0" style="font-size:.875rem;color:var(--text-secondary)">
            Sudah punya akun? <a href="{{ route('login') }}" style="color:var(--primary-600);font-weight:600">Masuk</a>
        </p>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
<script>document.addEventListener('DOMContentLoaded', () => lucide.createIcons())</script>
</body>
</html>
