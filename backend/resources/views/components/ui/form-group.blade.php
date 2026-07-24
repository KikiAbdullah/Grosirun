@props(['label'=>'','name'=>'','hint'=>null,'required'=>false])
@php $err = $errors->has($name); @endphp
<div class="form-group">
    @if($label)<label for="{{ $name }}" class="form-label">{{ $label }}@if($required) <span class="text-danger-600">*</span>@endif</label>@endif
    {{ $slot }}
    @if($err)<p class="form-error" role="alert">{{ $errors->first($name) }}</p>
    @elseif($hint)<p class="form-hint">{{ $hint }}</p>@endif
</div>
