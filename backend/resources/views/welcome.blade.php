<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Grosirun — Belanja Patungan</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="{{ asset('css/app.css') }}">
</head>
<body style="background:var(--surface-50)">
<div class="min-vh-100 d-flex flex-column">
    {{-- Header --}}
    <header class="px-4 py-4">
        <div class="mx-auto d-flex align-items-center justify-content-between" style="max-width:75rem">
            <div class="d-flex align-items-center gap-2">
                <div class="d-flex align-items-center justify-content-center rounded-3 text-white"
                     style="width:2.5rem;height:2.5rem;background:var(--primary-500)">
                    <i data-lucide="shopping-bag" style="width:1.25rem;height:1.25rem"></i>
                </div>
                <span class="fw-bold" style="font-size:1.1rem;color:var(--text-primary)">Grosirun</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <x-ui.button variant="secondary" size="sm" href="{{ route('login') }}">Masuk</x-ui.button>
                <x-ui.button variant="primary" size="sm" href="{{ route('register') }}" icon="user-plus">Daftar</x-ui.button>
            </div>
        </div>
    </header>

    {{-- Hero --}}
    <main class="flex-grow-1 d-flex align-items-center justify-content-center px-4">
        <div class="text-center py-5" style="max-width:48rem">
            <div class="d-inline-flex align-items-center gap-2 px-3 py-2 rounded-pill mb-4"
                 style="background:var(--primary-50);color:var(--primary-600);font-size:.875rem;font-weight:600">
                <i data-lucide="sparkles" style="width:1rem;height:1rem"></i>
                Platform Patungan Non-Escrow
            </div>
            <h1 class="fw-black mb-4" style="font-size:clamp(2rem,6vw,4rem);line-height:1.1;color:var(--text-primary)">
                Yuk, <span style="color:var(--primary-500)">Grosirun</span> Bareng!
            </h1>
            <p class="mb-5 mx-auto" style="font-size:1.1rem;color:var(--text-secondary);max-width:36rem">
                Patungan belanja sembako lebih murah untuk satu RT. Harga grosir, kualitas terbaik.
            </p>
            <div class="d-flex flex-column flex-sm-row align-items-center justify-content-center gap-3">
                <x-ui.button variant="primary" href="{{ route('register') }}" icon="rocket" size="lg">Mulai Patungan</x-ui.button>
                <x-ui.button variant="secondary" href="{{ route('login') }}" icon="log-in" size="lg">Sudah Punya Akun</x-ui.button>
            </div>

            {{-- Features --}}
            <div class="row g-4 mt-5 text-center">
                <div class="col-12 col-sm-4">
                    <div class="d-flex align-items-center justify-content-center rounded-3 mx-auto mb-3"
                         style="width:3.5rem;height:3.5rem;background:var(--primary-50)">
                        <i data-lucide="users" style="width:1.75rem;height:1.75rem;color:var(--primary-500)"></i>
                    </div>
                    <h3 class="fw-semibold mb-1" style="font-size:1rem">Patungan Satu RT</h3>
                    <p style="font-size:.875rem;color:var(--text-secondary)">Bergabung dengan tetangga untuk harga grosir.</p>
                </div>
                <div class="col-12 col-sm-4">
                    <div class="d-flex align-items-center justify-content-center rounded-3 mx-auto mb-3"
                         style="width:3.5rem;height:3.5rem;background:var(--info-50)">
                        <i data-lucide="shield-check" style="width:1.75rem;height:1.75rem;color:var(--info-500)"></i>
                    </div>
                    <h3 class="fw-semibold mb-1" style="font-size:1rem">Transparan &amp; Aman</h3>
                    <p style="font-size:.875rem;color:var(--text-secondary)">Audit trail lengkap, data terlindungi.</p>
                </div>
                <div class="col-12 col-sm-4">
                    <div class="d-flex align-items-center justify-content-center rounded-3 mx-auto mb-3"
                         style="width:3.5rem;height:3.5rem;background:var(--warning-50)">
                        <i data-lucide="smartphone" style="width:1.75rem;height:1.75rem;color:var(--warning-600)"></i>
                    </div>
                    <h3 class="fw-semibold mb-1" style="font-size:1rem">Ringan &amp; Cepat</h3>
                    <p style="font-size:.875rem;color:var(--text-secondary)">APK &lt;10MB, support HP lama.</p>
                </div>
            </div>
        </div>
    </main>

    {{-- Footer --}}
    <footer class="border-top py-4 px-4">
        <div class="mx-auto text-center" style="max-width:75rem;font-size:.75rem;color:var(--text-secondary)">
            &copy; 2026 Grosirun. UU PDP Compliant.
        </div>
    </footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>
<script>document.addEventListener('DOMContentLoaded', () => lucide.createIcons())</script>
</body>
</html>
