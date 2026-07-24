@if(session('success'))
<div class="alert d-flex align-items-center gap-2 mb-3 alert-dismissible"
     style="background:var(--primary-50);border-left:4px solid var(--primary-500);border-radius:0 .75rem .75rem 0;color:var(--primary-700)"
     x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,5000)"
     x-transition:leave="transition ease-in duration-200"
     x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <i data-lucide="check-circle" style="width:1.1rem;height:1.1rem;color:var(--primary-500);flex-shrink:0"></i>
    <span style="font-size:.875rem;font-weight:500">{{ session('success') }}</span>
    <button type="button" @click="show=false" class="btn-close ms-auto" style="font-size:.75rem" aria-label="Tutup"></button>
</div>
@endif

@if(session('error'))
<div class="alert d-flex align-items-center gap-2 mb-3 alert-dismissible"
     style="background:var(--danger-50);border-left:4px solid var(--danger-600);border-radius:0 .75rem .75rem 0;color:var(--danger-700)"
     x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,8000)"
     x-transition:leave="transition ease-in duration-200"
     x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <i data-lucide="alert-circle" style="width:1.1rem;height:1.1rem;color:var(--danger-600);flex-shrink:0"></i>
    <span style="font-size:.875rem;font-weight:500">{{ session('error') }}</span>
    <button type="button" @click="show=false" class="btn-close ms-auto" style="font-size:.75rem"></button>
</div>
@endif

@if(session('warning'))
<div class="alert d-flex align-items-center gap-2 mb-3 alert-dismissible"
     style="background:var(--warning-50);border-left:4px solid var(--warning-500);border-radius:0 .75rem .75rem 0;color:var(--warning-600)"
     x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,6000)"
     x-transition:leave="transition ease-in duration-200"
     x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <i data-lucide="alert-triangle" style="width:1.1rem;height:1.1rem;color:var(--warning-600);flex-shrink:0"></i>
    <span style="font-size:.875rem;font-weight:500">{{ session('warning') }}</span>
    <button type="button" @click="show=false" class="btn-close ms-auto" style="font-size:.75rem"></button>
</div>
@endif

@if(session('info'))
<div class="alert d-flex align-items-center gap-2 mb-3 alert-dismissible"
     style="background:var(--info-50);border-left:4px solid var(--info-500);border-radius:0 .75rem .75rem 0;color:var(--info-600)"
     x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,5000)"
     x-transition:leave="transition ease-in duration-200"
     x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <i data-lucide="info" style="width:1.1rem;height:1.1rem;color:var(--info-500);flex-shrink:0"></i>
    <span style="font-size:.875rem;font-weight:500">{{ session('info') }}</span>
    <button type="button" @click="show=false" class="btn-close ms-auto" style="font-size:.75rem"></button>
</div>
@endif
