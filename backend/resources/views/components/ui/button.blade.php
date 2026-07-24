@props(['variant'=>'primary','size'=>'md','type'=>'button','href'=>null,'loading'=>false,'disabled'=>false,'icon'=>null])
@php
    $c = match($variant){'secondary'=>'btn-secondary','danger'=>'btn-danger','ghost'=>'btn-ghost',default=>'btn-primary'};
    $c .= $size==='sm' ? ' btn-sm' : ($size==='lg' ? ' btn-lg' : '');
@endphp
@if($href)
    <a href="{{ $href }}" {{ $attributes->merge(['class'=>$c]) }}>@if($icon)<i data-lucide="{{ $icon }}" class="w-4 h-4"></i>@endif{{ $slot }}</a>
@else
    <button type="{{ $type }}" {{ $disabled||$loading?'disabled':'' }} {{ $attributes->merge(['class'=>$c]) }}>
        @if($loading)<svg class="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/></svg>
        @elseif($icon)<i data-lucide="{{ $icon }}" class="w-4 h-4"></i>@endif
        {{ $slot }}
    </button>
@endif
