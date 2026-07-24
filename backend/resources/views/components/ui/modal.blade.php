@props(['name','title'=>'','maxWidth'=>'lg'])
@php
    $mw = match($maxWidth) {
        'sm'  => '24rem',
        'md'  => '28rem',
        'xl'  => '48rem',
        '2xl' => '56rem',
        default => '32rem',
    };
@endphp
<div x-data="{ show: false }"
     @open-modal.window="if($event.detail==='{{ $name }}') show=true"
     @close-modal.window="if($event.detail==='{{ $name }}') show=false"
     @keydown.escape.window="show=false"
     x-show="show" x-cloak
     style="position:fixed;inset:0;z-index:1055">
    {{-- Backdrop --}}
    <div x-show="show"
         x-transition:enter="transition ease-out duration-200"
         x-transition:enter-start="opacity-0" x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-150"
         x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0"
         class="gr-modal-backdrop" @click="show=false"></div>
    {{-- Panel --}}
    <div class="gr-modal-panel">
        <div x-show="show"
             x-transition:enter="transition ease-out duration-200"
             x-transition:enter-start="opacity-0 translate-y-4" x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-150"
             x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0 translate-y-4"
             x-trap.inert.noscroll="show"
             class="gr-modal-content" style="max-width:{{ $mw }}" role="dialog" aria-modal="true">
            @if($title)
            <div class="d-flex align-items-center justify-content-between p-3 p-sm-4 border-bottom">
                <h2 class="mb-0 fw-semibold" style="font-size:1.05rem">{{ $title }}</h2>
                <button @click="show=false" class="gr-btn-icon" aria-label="Tutup">
                    <i data-lucide="x" style="width:1.25rem;height:1.25rem"></i>
                </button>
            </div>
            @endif
            <div class="p-3 p-sm-4">{{ $slot }}</div>
            @if(isset($footer))
            <div class="d-flex align-items-center justify-content-end gap-2 p-3 p-sm-4 border-top"
                 style="background:var(--surface-50);border-radius:0 0 1rem 1rem">
                {{ $footer }}
            </div>
            @endif
        </div>
    </div>
</div>
