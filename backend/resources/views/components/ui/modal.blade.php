@props(['name','title'=>'','maxWidth'=>'lg'])
@php $mw = match($maxWidth){'sm'=>'max-w-sm','md'=>'max-w-md','xl'=>'max-w-xl','2xl'=>'max-w-2xl',default=>'max-w-lg'}; @endphp
<div x-data="{ show: false }" @open-modal.window="if($event.detail==='{{ $name }}') show=true" @close-modal.window="if($event.detail==='{{ $name }}') show=false" @keydown.escape.window="show=false" x-show="show" x-cloak class="fixed inset-0 z-50">
    <div x-show="show" x-transition:enter="ease-out duration-200" x-transition:enter-start="opacity-0" x-transition:enter-end="opacity-100" x-transition:leave="ease-in duration-150" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0" class="modal-backdrop" @click="show=false"></div>
    <div class="modal-panel">
        <div x-show="show" x-transition:enter="ease-out duration-200" x-transition:enter-start="opacity-0 translate-y-4" x-transition:enter-end="opacity-100 translate-y-0" x-transition:leave="ease-in duration-150" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0 translate-y-4" x-trap.inert.noscroll="show" class="modal-content {{ $mw }} w-full" role="dialog" aria-modal="true">
            @if($title)<div class="flex items-center justify-between p-4 sm:p-6 border-b border-surface-200"><h2 class="text-title-lg">{{ $title }}</h2><button @click="show=false" class="btn-icon" aria-label="Tutup"><i data-lucide="x" class="w-5 h-5"></i></button></div>@endif
            <div class="p-4 sm:p-6">{{ $slot }}</div>
            @if(isset($footer))<div class="flex items-center justify-end gap-3 p-4 sm:p-6 border-t border-surface-200 bg-surface-50 rounded-b-2xl">{{ $footer }}</div>@endif
        </div>
    </div>
</div>
