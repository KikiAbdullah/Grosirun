@php
    $user   = auth()->user();
    $role   = session('active_role', $user?->active_role ?? 'buyer');
    $unread = $user?->unreadNotifications?->count() ?? 0;
    $roleBadge = match($role) {
        'admin'     => 'bg-danger-50 text-danger-600',
        'seller'    => 'bg-warning-50 text-warning-600',
        'initiator' => 'bg-primary-50 text-primary-600',
        default     => 'bg-info-50 text-info-600',
    };
    $roleDot = match($role) {
        'admin'     => 'var(--danger-500)',
        'seller'    => 'var(--warning-500)',
        'initiator' => 'var(--primary-500)',
        default     => 'var(--info-500)',
    };
@endphp

<header class="gr-navbar">
    {{-- Toggle Sidebar Button --}}
    <button @click="toggleSidebar()" class="gr-btn-icon" aria-label="Toggle sidebar">
        <i data-lucide="panel-left" style="width:1.25rem;height:1.25rem"></i>
    </button>

    {{-- Search Bar --}}
    <div class="d-none d-md-flex align-items-center flex-grow-1 mx-3" style="max-width:28rem">
        <div class="position-relative w-100">
            <i data-lucide="search" style="width:1rem;height:1rem;color:var(--text-disabled);position:absolute;left:.75rem;top:50%;transform:translateY(-50%)"></i>
            <input type="search" placeholder="Cari campaign, order..."
                   class="gr-form-input" style="padding-left:2.25rem;padding-top:.5rem;padding-bottom:.5rem"
                   aria-label="Pencarian">
        </div>
    </div>

    {{-- Right Side --}}
    <div class="d-flex align-items-center gap-2">
        {{-- Role Badge --}}
        <span class="d-none d-sm-inline-flex align-items-center gap-1 gr-badge {{ $roleBadge }}">
            <span style="width:.4rem;height:.4rem;border-radius:50%;background:{{ $roleDot }};display:inline-block"></span>
            {{ ucfirst($role) }}
        </span>

        {{-- Notifications --}}
        <a href="{{ route('notifications.index') }}" class="gr-btn-icon position-relative" aria-label="Notifikasi">
            <i data-lucide="bell" style="width:1.25rem;height:1.25rem"></i>
            @if($unread > 0)
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill text-white"
                  style="font-size:.625rem;background:var(--danger-600);transform:translate(-60%,-20%)!important">
                {{ min($unread, 99) }}
            </span>
            @endif
        </a>

        {{-- User Dropdown --}}
        <div x-data="{open:false}" class="position-relative">
            <button @click="open=!open" @click.outside="open=false" @keydown.escape.window="open=false"
                    class="d-flex align-items-center gap-2 p-1 rounded-3 border-0 bg-transparent"
                    style="cursor:pointer;transition:background .15s"
                    :style="open ? 'background:var(--surface-100)' : ''"
                    aria-expanded="open">
                <div class="d-flex align-items-center justify-content-center rounded-circle text-white fw-bold"
                     style="width:2rem;height:2rem;background:var(--primary-500);font-size:.875rem">
                    {{ strtoupper(substr($user?->name ?? '?', 0, 1)) }}
                </div>
                <span class="d-none d-sm-block text-truncate fw-medium" style="font-size:.875rem;max-width:8rem;color:var(--text-primary)">
                    {{ $user?->name ?? 'Guest' }}
                </span>
                <i data-lucide="chevron-down" class="d-none d-sm-block" style="width:1rem;height:1rem;color:var(--text-secondary)"></i>
            </button>

            <div x-show="open" x-cloak
                 x-transition:enter="transition ease-out duration-150"
                 x-transition:enter-start="opacity-0 translate-y-1"
                 x-transition:enter-end="opacity-100 translate-y-0"
                 x-transition:leave="transition ease-in duration-100"
                 x-transition:leave-start="opacity-100"
                 x-transition:leave-end="opacity-0"
                 class="position-absolute end-0 mt-2 bg-white rounded-3 border shadow-sm py-2"
                 style="width:14rem;z-index:1050" role="menu">
                <div class="px-3 py-2 border-bottom">
                    <p class="mb-0 fw-medium" style="font-size:.875rem">{{ $user?->name }}</p>
                    <p class="mb-0" style="font-size:.75rem;color:var(--text-secondary)">{{ $user?->phone_number }}</p>
                </div>
                <a href="{{ route('profile.index') }}" class="d-flex align-items-center gap-2 px-3 py-2 text-decoration-none"
                   style="font-size:.875rem;color:var(--text-secondary)" role="menuitem">
                    <i data-lucide="user" style="width:1rem;height:1rem"></i>Profil
                </a>
                <hr class="my-1" style="border-color:var(--surface-200)">
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="d-flex align-items-center gap-2 w-100 px-3 py-2 border-0 bg-transparent text-start"
                            style="font-size:.875rem;color:var(--danger-600);cursor:pointer" role="menuitem">
                        <i data-lucide="log-out" style="width:1rem;height:1rem"></i>Keluar
                    </button>
                </form>
            </div>
        </div>
    </div>
</header>
