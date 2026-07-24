@props(['variant'=>'primary','size'=>'md','type'=>'button','href'=>null,'loading'=>false,'disabled'=>false,'icon'=>null])
@php
    $cls = 'gr-btn gr-btn-' . match($variant) {
        'secondary' => 'secondary',
        'danger'    => 'danger',
        'ghost'     => 'ghost',
        default     => 'primary',
    };
    $cls .= match($size) {
        'sm' => ' gr-btn-sm',
        'lg' => ' gr-btn-lg',
        default => '',
    };
@endphp
@if($href)
    <a href="{{ $href }}" {{ $attributes->merge(['class' => $cls]) }}>
        @if($icon)<i data-lucide="{{ $icon }}" style="width:1rem;height:1rem"></i>@endif
        {{ $slot }}
    </a>
@else
    <button type="{{ $type }}" {{ ($disabled || $loading) ? 'disabled' : '' }} {{ $attributes->merge(['class' => $cls]) }}>
        @if($loading)
            <svg class="spin" style="width:1rem;height:1rem" viewBox="0 0 24 24" fill="none">
                <circle style="opacity:.25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                <path style="opacity:.75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
            </svg>
        @elseif($icon)
            <i data-lucide="{{ $icon }}" style="width:1rem;height:1rem"></i>
        @endif
        {{ $slot }}
    </button>
@endif
