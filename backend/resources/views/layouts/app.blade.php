<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title','Dashboard') — Grosirun</title>
    @vite(['resources/css/app.css','resources/js/app.js'])
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    @stack('styles')
</head>
<body class="bg-surface-50 font-sans antialiased text-text-primary" x-data="offlineDetector()">
    <div x-show="isOffline" x-cloak x-transition class="offline-banner"><i data-lucide="wifi-off" class="w-4 h-4"></i><span>Kamu offline — data mungkin tidak terbaru</span></div>
    <div class="min-h-screen flex" x-data="sidebar()">
        <div x-show="mobileOpen" x-transition:enter="ease-out duration-200" x-transition:enter-start="opacity-0" x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-150" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0" @click="mobileOpen=false" class="fixed inset-0 z-30 bg-black/40 lg:hidden" x-cloak></div>
        @include('components.sidebar')
        <div class="flex-1 flex flex-col min-h-screen transition-all duration-300" :class="{'lg:ml-64':open,'ml-0':!open}">
            @include('components.navbar')
            <main class="flex-1 overflow-y-auto" role="main"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6"><x-ui-alert />@yield('content')</div></main>
            <footer class="bg-white border-t border-surface-200 py-4 mt-auto"><div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"><div class="flex flex-col sm:flex-row items-center justify-between text-xs text-text-secondary"><p>&copy; 2026 Grosirun. Non-escrow group-buying.</p><p class="mt-1 sm:mt-0 flex items-center gap-1"><i data-lucide="code" class="w-3 h-3"></i>Laravel {{ Illuminate\Foundation\Application::VERSION }}</p></div></div></footer>
        </div>
    </div>
    @stack('scripts')
</body>
</html>
