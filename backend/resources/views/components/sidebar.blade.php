@php
    $role = session('active_role', auth()->user()->active_role ?? 'buyer');
    $cr   = request()->route()?->getName() ?? '';
    $menus = [
        'buyer'     => [['Beranda','layout-dashboard','dashboard'],['Campaign','shopping-cart','campaigns.index'],['Pesanan Saya','receipt','orders.index']],
        'initiator' => [['Beranda','layout-dashboard','dashboard'],['Campaign','shopping-cart','campaigns.index'],['Kelola Campaign','settings','campaigns.manage'],['Validasi Order','check-square','orders.validate'],['Distribusi','truck','distribution.index'],['Purchase Order','file-text','purchase-orders.index']],
        'seller'    => [['Beranda','layout-dashboard','dashboard'],['Produk','package','products.index'],['Offer','tags','offers.index'],['Purchase Order','file-text','purchase-orders.index']],
        'admin'     => [['Dashboard','layout-dashboard','admin.dashboard'],['Verifikasi Supplier','shield-check','admin.suppliers.pending'],['Moderasi Offer','clipboard-check','admin.offers.moderate'],['Kelola User','users','admin.users.index'],['Dispute','alert-triangle','admin.disputes.index'],['Audit Log','history','admin.audit-logs']],
    ];
    $shared = [['Notifikasi','bell','notifications.index'],['Profil','user','profile.index']];
    $items  = $menus[$role] ?? $menus['buyer'];
@endphp

<aside id="gr-sidebar" class="gr-sidebar scrollbar-hide" aria-label="Sidebar">
    {{-- Logo --}}
    <div class="d-flex align-items-center gap-2 px-3 py-0 border-bottom" style="height:4rem;flex-shrink:0">
        <a href="/dashboard" class="d-flex align-items-center gap-2 text-decoration-none">
            <div class="d-flex align-items-center justify-content-center rounded-3 text-white" style="width:2rem;height:2rem;background:var(--primary-500)">
                <i data-lucide="shopping-bag" style="width:1.1rem;height:1.1rem"></i>
            </div>
            <span class="fw-bold" style="font-size:1rem;color:var(--text-primary)">Grosirun</span>
        </a>
    </div>

    {{-- Navigation --}}
    <nav class="flex-grow-1 overflow-y-auto py-3 px-2 scrollbar-hide" role="navigation">
        <div class="px-2 mb-2">
            <span style="font-size:.7rem;font-weight:700;color:var(--text-disabled);text-transform:uppercase;letter-spacing:.06em">
                {{ ucfirst($role) }}
            </span>
        </div>
        <ul class="list-unstyled mb-0">
            @foreach($items as $m)
            <li class="mb-1">
                <a href="{{ route($m[2]) }}"
                   class="gr-sidebar-link {{ str_starts_with($cr, explode('.',$m[2])[0]) ? 'active' : '' }}">
                    <i data-lucide="{{ $m[1] }}" style="width:1.1rem;height:1.1rem;flex-shrink:0"></i>
                    <span>{{ $m[0] }}</span>
                </a>
            </li>
            @endforeach
        </ul>

        <hr class="my-3" style="border-color:var(--surface-200)">

        <div class="px-2 mb-2">
            <span style="font-size:.7rem;font-weight:700;color:var(--text-disabled);text-transform:uppercase;letter-spacing:.06em">Umum</span>
        </div>
        <ul class="list-unstyled mb-0">
            @foreach($shared as $m)
            <li class="mb-1">
                <a href="{{ route($m[2]) }}"
                   class="gr-sidebar-link {{ $cr === $m[2] ? 'active' : '' }}">
                    <i data-lucide="{{ $m[1] }}" style="width:1.1rem;height:1.1rem;flex-shrink:0"></i>
                    <span>{{ $m[0] }}</span>
                </a>
            </li>
            @endforeach
        </ul>
    </nav>

    {{-- Footer --}}
    <div class="border-top px-3 py-3" style="flex-shrink:0">
        <div class="d-flex align-items-center gap-2" style="font-size:.8rem;color:var(--text-secondary)">
            <i data-lucide="map-pin" style="width:1rem;height:1rem;color:var(--primary-500)"></i>
            <span>PGH-RT03 Permata Hijau</span>
        </div>
    </div>
</aside>
