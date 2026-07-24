@props(['hoverable'=>false,'padding'=>'md'])
@php $c = ($hoverable?'card-hover':'card').' '.match($padding){'sm'=>'p-3','lg'=>'p-6 sm:p-8','none'=>'',default=>'p-4 sm:p-6'}; @endphp
<div {{ $attributes->merge(['class'=>$c]) }}>{{ $slot }}</div>
