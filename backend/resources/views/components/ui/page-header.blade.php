@props(['title','subtitle'=>null])
<div class="d-flex flex-column flex-sm-row align-items-sm-center justify-content-sm-between gap-3 mb-4">
    <div>
        <h1 class="mb-0 fw-bold" style="font-size:1.5rem;color:var(--text-primary)">{{ $title }}</h1>
        @if($subtitle)
        <p class="mb-0 mt-1" style="font-size:.875rem;color:var(--text-secondary)">{{ $subtitle }}</p>
        @endif
    </div>
    @if($actions ?? false)
    <div class="d-flex align-items-center gap-2 flex-shrink-0">{{ $actions }}</div>
    @endif
</div>
