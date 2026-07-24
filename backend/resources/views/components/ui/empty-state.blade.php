@props(['icon'=>'inbox','title'=>'Tidak ada data','description'=>'','actionLabel'=>null,'actionUrl'=>null])
<div class="gr-empty-state" {{ $attributes }}>
    <div class="gr-empty-state-icon">
        <i data-lucide="{{ $icon }}" style="width:2rem;height:2rem;color:var(--text-disabled)"></i>
    </div>
    <h3 class="fw-semibold mb-1" style="font-size:1.1rem;color:var(--text-primary)">{{ $title }}</h3>
    @if($description)
    <p class="mb-3" style="font-size:.875rem;color:var(--text-secondary);max-width:20rem">{{ $description }}</p>
    @endif
    @if($actionLabel && $actionUrl)
    <a href="{{ $actionUrl }}" class="gr-btn gr-btn-primary">
        <i data-lucide="plus" style="width:1rem;height:1rem"></i>{{ $actionLabel }}
    </a>
    @endif
    {{ $slot ?? '' }}
</div>
