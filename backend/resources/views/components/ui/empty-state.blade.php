@props(['icon'=>'inbox','title'=>'Tidak ada data','description'=>'','actionLabel'=>null,'actionUrl'=>null])
<div class="empty-state" {{ $attributes }}>
    <div class="empty-state-icon"><i data-lucide="{{ $icon }}" class="w-8 h-8 text-text-disabled"></i></div>
    <h3 class="empty-state-title">{{ $title }}</h3>
    @if($description)<p class="empty-state-description">{{ $description }}</p>@endif
    @if($actionLabel&&$actionUrl)
        <a href="{{ $actionUrl }}" class="btn-primary"><i data-lucide="plus" class="w-4 h-4"></i>{{ $actionLabel }}</a>
    @endif
    {{ $slot ?? '' }}
</div>
