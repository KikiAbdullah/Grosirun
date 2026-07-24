@php $user=auth()->user(); $role=session('active_role',$user?->active_role??'buyer'); $unread=$user?->unreadNotifications?->count()??0; @endphp
<header class="h-16 bg-white border-b border-surface-200 flex items-center justify-between px-4 sm:px-6 lg:px-8 sticky top-0 z-20">
    <button @click="mobileOpen=!mobileOpen" class="btn-icon lg:hidden" aria-label="Toggle menu"><i data-lucide="menu" class="w-5 h-5"></i></button>
    <button @click="open=!open" class="btn-icon hidden lg:flex" aria-label="Toggle sidebar"><i data-lucide="panel-left" class="w-5 h-5"></i></button>
    <div class="hidden md:flex items-center flex-1 max-w-md mx-4"><div class="relative w-full"><i data-lucide="search" class="w-4 h-4 text-text-disabled absolute left-3 top-1/2 -translate-y-1/2"></i><input type="search" placeholder="Cari campaign, order..." class="form-input pl-10 py-2 text-sm" aria-label="Pencarian"></div></div>
    <div class="flex items-center gap-2">
        <span class="hidden sm:inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold {{ match($role){'admin'=>'bg-danger-50 text-danger-600','seller'=>'bg-warning-50 text-warning-600','initiator'=>'bg-primary-50 text-primary-600',default=>'bg-info-50 text-info-600'} }}"><span class="w-1.5 h-1.5 rounded-full {{ match($role){'admin'=>'bg-danger-500','seller'=>'bg-warning-500','initiator'=>'bg-primary-500',default=>'bg-info-500'} }}"></span>{{ ucfirst($role) }}</span>
        <a href="{{ route('notifications.index') }}" class="btn-icon relative" aria-label="Notifikasi"><i data-lucide="bell" class="w-5 h-5"></i>@if($unread>0)<span class="absolute -top-0.5 -right-0.5 w-5 h-5 bg-danger-600 text-white text-[10px] font-bold rounded-full flex items-center justify-center">{{ min($unread,99) }}</span>@endif</a>
        <div x-data="{dropdownOpen:false}" class="relative">
            <button @click="dropdownOpen=!dropdownOpen" @click.outside="dropdownOpen=false" @keydown.escape="dropdownOpen=false" class="flex items-center gap-2 p-1.5 rounded-xl hover:bg-surface-100 transition-colors" aria-expanded="dropdownOpen">
                <div class="w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center"><span class="text-white text-sm font-bold">{{ strtoupper(substr($user?->name??'?',0,1)) }}</span></div>
                <span class="hidden sm:block text-sm font-medium max-w-[120px] truncate">{{ $user?->name??'Guest' }}</span>
                <i data-lucide="chevron-down" class="w-4 h-4 text-text-secondary hidden sm:block"></i>
            </button>
            <div x-show="dropdownOpen" x-transition:enter="ease-out duration-150" x-transition:enter-start="opacity-0 translate-y-1" x-transition:enter-end="opacity-100 translate-y-0" x-transition:leave="ease-in duration-100" x-cloak class="absolute right-0 mt-2 w-56 bg-white rounded-xl border border-surface-200 shadow-lg py-2 z-50" role="menu">
                <div class="px-4 py-2 border-b border-surface-200"><p class="text-sm font-medium">{{ $user?->name }}</p><p class="text-xs text-text-secondary">{{ $user?->phone_number }}</p></div>
                <a href="{{ route('profile.index') }}" class="flex items-center gap-2 px-4 py-2 text-sm text-text-secondary hover:bg-surface-50" role="menuitem"><i data-lucide="user" class="w-4 h-4"></i>Profil</a>
                <div class="border-t border-surface-200 my-1"></div>
                <form method="POST" action="{{ route('logout') }}">@csrf<button type="submit" class="flex items-center gap-2 w-full px-4 py-2 text-sm text-danger-600 hover:bg-danger-50" role="menuitem"><i data-lucide="log-out" class="w-4 h-4"></i>Keluar</button></form>
            </div>
        </div>
    </div>
</header>
