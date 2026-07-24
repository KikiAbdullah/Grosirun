@extends('layouts.app')
@section('title','Notifikasi')
@section('content')

<x-ui.page-header title="Notifikasi" subtitle="Update transaksi &amp; campaign.">
    <x-slot:actions>
        <form method="POST" action="{{ route('notifications.read-all') }}">
            @csrf
            <x-ui.button type="submit" variant="ghost" size="sm" icon="check-check">Tandai Semua</x-ui.button>
        </form>
    </x-slot:actions>
</x-ui.page-header>

{{-- Filter --}}
<form method="GET" class="d-flex flex-column flex-sm-row gap-2 mb-4">
    <div class="position-relative flex-grow-1">
        <i data-lucide="search" style="width:1rem;height:1rem;color:var(--text-disabled);position:absolute;left:.75rem;top:50%;transform:translateY(-50%)"></i>
        <input type="search" name="search" value="{{ $search ?? '' }}"
               placeholder="Cari notifikasi..."
               class="gr-form-input" style="padding-left:2.25rem">
    </div>
    <select name="read" onchange="this.form.submit()" class="gr-form-input" style="max-width:10rem">
        <option value="">Semua</option>
        <option value="0" {{ ($read ?? '') === '0' ? 'selected' : '' }}>Belum Dibaca</option>
        <option value="1" {{ ($read ?? '') === '1' ? 'selected' : '' }}>Sudah Dibaca</option>
    </select>
</form>

<p class="mb-3" style="font-size:.875rem;color:var(--text-secondary)">{{ $notifications->total() }} notifikasi</p>

<div class="d-flex flex-column gap-3">
    @forelse($notifications as $n)
    <div class="gr-card p-3 {{ !$n->read_at ? '' : '' }}"
         style="{{ !$n->read_at ? 'border-left:4px solid var(--primary-500)' : '' }}">
        <div class="d-flex align-items-start gap-3">
            <div class="d-flex align-items-center justify-content-center rounded-circle flex-shrink-0"
                 style="width:2.5rem;height:2.5rem;background:{{ !$n->read_at ? 'var(--primary-50)' : 'var(--surface-100)' }}">
                <i data-lucide="{{ !$n->read_at ? 'bell' : 'bell-off' }}"
                   style="width:1.1rem;height:1.1rem;color:{{ !$n->read_at ? 'var(--primary-500)' : 'var(--text-disabled)' }}"></i>
            </div>
            <div class="flex-grow-1">
                <h3 class="fw-semibold mb-1" style="font-size:.875rem">{{ $n->data['title'] ?? 'Notifikasi' }}</h3>
                <p class="mb-1" style="font-size:.8rem;color:var(--text-secondary)">{{ $n->data['body'] ?? '' }}</p>
                <p class="mb-0" style="font-size:.75rem;color:var(--text-disabled)">{{ $n->created_at->diffForHumans() }}</p>
            </div>
        </div>
    </div>
    @empty
    <x-ui.empty-state icon="bell-off" title="Tidak ada notifikasi" />
    @endforelse

    {{ $notifications->links() }}
</div>
@endsection
