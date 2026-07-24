@if(session('success'))
<div class="mb-4 bg-primary-50 border-l-4 border-primary-500 p-4 rounded-r-xl animate-slide-up" x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,5000)" x-transition:leave="ease-in duration-200" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <div class="flex items-center"><i data-lucide="check-circle" class="w-5 h-5 text-primary-500 mr-3 flex-shrink-0"></i><p class="text-sm font-medium text-primary-700 flex-1">{{ session('success') }}</p><button @click="show=false" class="text-primary-400 hover:text-primary-600 ml-2" aria-label="Tutup"><i data-lucide="x" class="w-4 h-4"></i></button></div>
</div>
@endif
@if(session('error'))
<div class="mb-4 bg-danger-50 border-l-4 border-danger-600 p-4 rounded-r-xl animate-slide-up" x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,8000)" x-transition:leave="ease-in duration-200" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <div class="flex items-center"><i data-lucide="alert-circle" class="w-5 h-5 text-danger-600 mr-3 flex-shrink-0"></i><p class="text-sm font-medium text-danger-700 flex-1">{{ session('error') }}</p><button @click="show=false" class="text-danger-400 hover:text-danger-600 ml-2"><i data-lucide="x" class="w-4 h-4"></i></button></div>
</div>
@endif
@if(session('warning'))
<div class="mb-4 bg-warning-50 border-l-4 border-warning-500 p-4 rounded-r-xl animate-slide-up" x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,6000)" x-transition:leave="ease-in duration-200" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <div class="flex items-center"><i data-lucide="alert-triangle" class="w-5 h-5 text-warning-600 mr-3 flex-shrink-0"></i><p class="text-sm font-medium text-warning-600 flex-1">{{ session('warning') }}</p><button @click="show=false" class="text-warning-400 hover:text-warning-600 ml-2"><i data-lucide="x" class="w-4 h-4"></i></button></div>
</div>
@endif
@if(session('info'))
<div class="mb-4 bg-info-50 border-l-4 border-info-500 p-4 rounded-r-xl animate-slide-up" x-data="{show:true}" x-show="show" x-init="setTimeout(()=>show=false,5000)" x-transition:leave="ease-in duration-200" x-transition:leave-start="opacity-100" x-transition:leave-end="opacity-0">
    <div class="flex items-center"><i data-lucide="info" class="w-5 h-5 text-info-500 mr-3 flex-shrink-0"></i><p class="text-sm font-medium text-info-600 flex-1">{{ session('info') }}</p><button @click="show=false" class="text-info-400 hover:text-info-600 ml-2"><i data-lucide="x" class="w-4 h-4"></i></button></div>
</div>
@endif
