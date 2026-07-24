@php
    $role = session('active_role', auth()->user()->active_role ?? 'buyer');
    $cr = request()->route()?->getName() ?? '';
    $menus = [
        'buyer'     => [['Beranda','layout-dashboard','dashboard'],['Campaign','shopping-cart','campaigns.index'],['Pesanan Saya','receipt','orders.index']],
        'initiator' => [['Beranda','layout-dashboard','dashboard'],['Campaign','shopping-cart','campaigns.index'],['Kelola Campaign','settings','campaigns.manage'],['Validasi Order','check-square','orders.validate'],['Distribusi','truck','distribution.index'],['Purchase Order','file-text','purchase-orders.index']],
        'seller'    => [['Beranda','layout-dashboard','dashboard'],['Produk','package','products.index'],['Offer','tags','offers.index'],['Purchase Order','file-text','purchase-orders.index']],
        'admin'     => [['Dashboard','layout-dashboard','admin.dashboard'],['Verifikasi Supplier','shield-check','admin.suppliers.pending'],['Moderasi Offer','clipboard-check','admin.offers.moderate'],['Kelola User','users','admin.users.index'],['Dispute','alert-triangle','admin.disputes.index'],['Audit Log','history','admin.audit-logs']],
    ];
    $shared = [['Notifikasi','bell','notifications.index'],['Profil','user','profile.index']];
    $items = $menus[$role] ?? $menus['buyer'];
@endphp
<aside class="fixed inset-y-0 left-0 z-40 w-64 bg-white border-r border-surface-200 flex flex-col transform transition-transform duration-300 lg:translate-x-0"
    :class="{'-translate-x-full':!mobileOpen&&window.innerWidth<1024,'translate-x-0':mobileOpen||window.innerWidth>=1024}" x-show="open||mobileOpen" x-cloak aria-label="Sidebar">
    <div class="h-16 flex items-center px-6 border-b border-surface-200 flex-shrink-0">
        <a href="/dashboard" class="flex items-center gap-2"><div class="w-8 h-8 bg-primary-500 rounded-lg flex items-center justify-center"><i data-lucide="shopping-bag" class="w-5 h-5 text-white"></i></div><span class="text-title-lg">Grosirun</span></a>
    </div>
    <nav class="flex-1 overflow-y-auto py-4 px-3 scrollbar-hide" role="navigation">
        <div class="px-3 mb-2"><span class="text-body-sm font-semibold text-text-disabled uppercase tracking-wider">{{ ucfirst($role) }}</span></div>
        <ul class="space-y-1">@foreach($items as $m)<li><a href="{{ route($m[2]) }}" class="{{ str_starts_with($cr, explode('.',$m[2])[0]) ? 'sidebar-link-active' : 'sidebar-link' }}"><i data-lucide="{{ $m[1] }}" class="w-5 h-5 flex-shrink-0"></i><span>{{ $m[0] }}</span></a></li>@endforeach</ul>
        <div class="border-t border-surface-200 my-4"></div>
        <div class="px-3 mb-2"><span class="text-body-sm font-semibold text-text-disabled uppercase tracking-wider">Umum</span></div>
        <ul class="space-y-1">@foreach($shared as $m)<li><a href="{{ route($m[2]) }}" class="{{ $cr===$m[2]?'sidebar-link-active':'sidebar-link' }}"><i data-lucide="{{ $m[1] }}" class="w-5 h-5 flex-shrink-0"></i><span>{{ $m[0] }}</span></a></li>@endforeach</ul>
    </nav>
    <div class="border-t border-surface-200 p-4 flex-shrink-0"><div class="flex items-center gap-2 text-body-sm text-text-secondary"><i data-lucide="map-pin" class="w-4 h-4 text-primary-500"></i><span>PGH-RT03 Permata Hijau</span></div></div>
</aside>
