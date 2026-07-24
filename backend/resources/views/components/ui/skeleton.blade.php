@props(['type'=>'card','count'=>1])
@switch($type)
    @case('text')
        @for($i=0;$i<$count;$i++)
        <div class="gr-skeleton mb-2" style="height:1rem;width:{{ rand(50,100) }}%"></div>
        @endfor
        @break
    @case('heading')
        <div class="gr-skeleton mb-2" style="height:1.5rem;width:50%"></div>
        @break
    @case('avatar')
        <div class="gr-skeleton rounded-circle" style="height:2.5rem;width:2.5rem"></div>
        @break
    @case('table-row')
        @for($i=0;$i<$count;$i++)
        <div class="d-flex align-items-center gap-3 py-3 {{ $i>0?'border-top':'' }}">
            <div class="gr-skeleton rounded-circle flex-shrink-0" style="height:2.5rem;width:2.5rem"></div>
            <div class="flex-grow-1">
                <div class="gr-skeleton mb-2" style="height:.875rem;width:40%"></div>
                <div class="gr-skeleton" style="height:.75rem;width:60%;opacity:.5"></div>
            </div>
            <div class="gr-skeleton" style="height:1.5rem;width:5rem"></div>
        </div>
        @endfor
        @break
    @case('metric')
        <div class="gr-card p-3">
            <div class="gr-skeleton mb-3" style="height:1rem;width:5rem"></div>
            <div class="gr-skeleton mb-2" style="height:2rem;width:4rem"></div>
            <div class="gr-skeleton" style="height:.75rem;width:6rem"></div>
        </div>
        @break
    @default
        @for($i=0;$i<$count;$i++)
        <div class="gr-card p-3 {{ $i>0?'mt-3':'' }}">
            <div class="gr-skeleton mb-3" style="height:10rem;border-radius:.75rem"></div>
            <div class="gr-skeleton mb-2" style="height:1.25rem;width:75%"></div>
            <div class="gr-skeleton mb-3" style="height:1rem;width:50%"></div>
            <div class="gr-skeleton" style="height:1.5rem;border-radius:9999px"></div>
        </div>
        @endfor
@endswitch
