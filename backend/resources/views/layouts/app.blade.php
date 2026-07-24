<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title','Dashboard') — Grosirun</title>

    {{-- Bootstrap 5 CSS --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    {{-- DataTables Bootstrap5 CSS --}}
    <link rel="stylesheet" href="https://cdn.datatables.net/2.0.8/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/3.0.2/css/buttons.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/select/2.0.3/css/select.bootstrap5.min.css">
    {{-- Notyf CSS --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/notyf@3/notyf.min.css">
    {{-- Tom Select CSS --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/css/tom-select.default.min.css">
    {{-- FilePond CSS --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/filepond@4/dist/filepond.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/filepond-plugin-image-preview@4/dist/filepond-plugin-image-preview.min.css">
    {{-- Flatpickr CSS --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    {{-- SweetAlert2 CSS --}}
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    {{-- Grosirun Custom CSS --}}
    <link rel="stylesheet" href="{{ asset('css/app.css') }}">
    @stack('styles')
</head>
<body x-data="offlineDetector()">

    {{-- Offline Banner --}}
    <div x-show="isOffline" x-cloak x-transition class="gr-offline-banner">
        <i data-lucide="wifi-off" style="width:1rem;height:1rem"></i>
        <span>Kamu offline — data mungkin tidak terbaru</span>
    </div>

    <div x-data="sidebar()">
        {{-- Mobile Overlay --}}
        <div id="sidebar-overlay"
             class="gr-sidebar-overlay d-lg-none"
             x-show="open && $el.ownerDocument.defaultView.innerWidth < 992"
             x-cloak
             @click="closeMobile()"></div>

        {{-- Sidebar --}}
        @include('components.sidebar')

        {{-- Main Wrapper --}}
        <div id="main-wrapper" class="gr-main-wrapper">
            @include('components.navbar')
            <main role="main" class="flex-grow-1">
                <div class="container-fluid px-4 py-4" style="max-width:1400px">
                    <x-ui.alert />
                    @yield('content')
                </div>
            </main>
            <footer class="bg-white border-top py-3 mt-auto">
                <div class="container-fluid px-4" style="max-width:1400px">
                    <div class="d-flex flex-column flex-sm-row align-items-center justify-content-between" style="font-size:.75rem;color:var(--text-secondary)">
                        <p class="mb-0">&copy; 2026 Grosirun. Non-escrow group-buying.</p>
                        <p class="mb-0 mt-1 mt-sm-0 d-flex align-items-center gap-1">
                            <i data-lucide="code" style="width:.75rem;height:.75rem"></i>
                            Laravel {{ Illuminate\Foundation\Application::VERSION }}
                        </p>
                    </div>
                </div>
            </footer>
        </div>
    </div>

    {{-- Alpine.js + Plugins (CDN) --}}
    <script src="https://cdn.jsdelivr.net/npm/@alpinejs/persist@3/dist/cdn.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/@alpinejs/collapse@3/dist/cdn.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/@alpinejs/focus@3/dist/cdn.min.js" defer></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js" defer></script>

    {{-- Lucide Icons --}}
    <script src="https://cdn.jsdelivr.net/npm/lucide@latest/dist/umd/lucide.min.js"></script>

    {{-- Bootstrap 5 Bundle (includes Popper) --}}
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    {{-- jQuery (required by DataTables) --}}
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    {{-- DataTables --}}
    <script src="https://cdn.datatables.net/2.0.8/js/dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/2.0.8/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/3.0.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/3.0.2/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/select/2.0.3/js/dataTables.select.min.js"></script>

    {{-- SweetAlert2 --}}
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    {{-- Notyf --}}
    <script src="https://cdn.jsdelivr.net/npm/notyf@3/notyf.min.js"></script>
    {{-- Tom Select --}}
    <script src="https://cdn.jsdelivr.net/npm/tom-select@2.3.1/dist/js/tom-select.complete.min.js"></script>
    {{-- Flatpickr --}}
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    {{-- FilePond --}}
    <script src="https://cdn.jsdelivr.net/npm/filepond-plugin-file-validate-size@2/dist/filepond-plugin-file-validate-size.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/filepond-plugin-file-validate-type@1/dist/filepond-plugin-file-validate-type.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/filepond-plugin-image-preview@4/dist/filepond-plugin-image-preview.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/filepond@4/dist/filepond.min.js"></script>
    {{-- Chart.js --}}
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    {{-- Grosirun App JS --}}
    <script src="{{ asset('js/app.js') }}"></script>

    @stack('scripts')
</body>
</html>
