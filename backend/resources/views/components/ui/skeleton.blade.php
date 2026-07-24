@props(['type'=>'card','count'=>1])
@switch($type)
    @case('text')    @for($i=0;$i<$count;$i++)<div class="skeleton-text {{ $i>0?'mt-2':'' }}" style="width:{{ rand(50,100) }}%"></div>@endfor @break
    @case('heading') <div class="skeleton-heading"></div> @break
    @case('avatar')  <div class="skeleton-avatar"></div> @break
    @case('table-row') @for($i=0;$i<$count;$i++)<div class="flex items-center gap-4 py-4 {{ $i>0?'border-t border-surface-200':'' }}"><div class="skeleton-avatar"></div><div class="flex-1 space-y-2"><div class="skeleton-text" style="width:40%"></div><div class="skeleton-text" style="width:60%;opacity:.5"></div></div><div class="skeleton h-6 w-20"></div></div>@endfor @break
    @case('metric')  <div class="card p-4 sm:p-6"><div class="skeleton h-4 w-20 mb-3"></div><div class="skeleton h-8 w-16 mb-2"></div><div class="skeleton h-3 w-24"></div></div> @break
    @default @for($i=0;$i<$count;$i++)<div class="card p-4 sm:p-6 {{ $i>0?'mt-4':'' }}"><div class="skeleton h-40 w-full rounded-xl mb-4"></div><div class="skeleton h-5 w-3/4 mb-2"></div><div class="skeleton h-4 w-1/2 mb-4"></div><div class="skeleton h-6 w-full rounded-full mb-4"></div></div>@endfor
@endswitch
