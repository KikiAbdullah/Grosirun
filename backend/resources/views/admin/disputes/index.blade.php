@extends('layouts.app')
@section('title','Dispute')
@section('content')

<x-ui.page-header title="Mediasi Dispute" subtitle="Tinjau sengketa fulfillment." />

<x-ui.card padding="none" class="p-3">
    {{ $dataTable->table(['id'=>'disputes-table','class'=>'table table-hover align-middle w-100']) }}
</x-ui.card>

@push('scripts')
{{ $dataTable->scripts(attributes:['type'=>'module']) }}
@endpush
@endsection
