@props(['title','subtitle'=>null])
<div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
    <div>
        <h1 class="text-headline-lg text-text-primary text-balance">{{ $title }}</h1>
        @if($subtitle)<p class="text-body-md text-text-secondary mt-1">{{ $subtitle }}</p>@endif
    </div>
    @if($actions ?? false)
        <div class="flex items-center gap-3 flex-shrink-0">{{ $actions }}</div>
    @endif
</div>
