@props(['hoverable'=>false,'padding'=>'md'])
@php
    $cls = $hoverable ? 'gr-card gr-card-hover' : 'gr-card';
    $pad = match($padding) {
        'sm'   => 'p-2',
        'lg'   => 'p-4 p-sm-5',
        'none' => '',
        default => 'p-3 p-sm-4',
    };
@endphp
<div {{ $attributes->merge(['class' => trim("$cls $pad")]) }}>{{ $slot }}</div>
