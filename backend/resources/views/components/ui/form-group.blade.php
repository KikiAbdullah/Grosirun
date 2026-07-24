@props(['label'=>'','name'=>'','hint'=>null,'required'=>false])
@php $err = $errors->has($name); @endphp
<div class="gr-form-group">
    @if($label)
    <label for="{{ $name }}" class="gr-form-label">
        {{ $label }}
        @if($required)<span style="color:var(--danger-600)">*</span>@endif
    </label>
    @endif
    {{ $slot }}
    @if($err)
        <p class="gr-form-error" role="alert">{{ $errors->first($name) }}</p>
    @elseif($hint)
        <p class="gr-form-hint">{{ $hint }}</p>
    @endif
</div>
