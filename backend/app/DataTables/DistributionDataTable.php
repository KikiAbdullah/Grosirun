<?php
namespace App\DataTables;
use App\Models\Order;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class DistributionDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('user_name', fn($o) => $o->user->name ?? '-')
            ->addColumn('campaign_title', fn($o) => $o->campaign->title ?? '-')
            ->editColumn('is_taken', fn($o) => $o->is_taken ? '<span class="badge badge-success">✓ Diambil</span>' : '<span class="badge badge-warning">Belum</span>')
            ->addColumn('action', function($o) {
                if ($o->is_taken) return '<span class="text-body-sm text-text-secondary">Selesai</span>';
                return '<form method="POST" action="' . route('orders.take', $o->uuid) . '"><input type="hidden" name="_token" value="' . csrf_token() . '"><button type="submit" class="btn btn-sm btn-primary"><i data-lucide="user-check" class="w-4 h-4 mr-1"></i>Centang Ambil</button></form>';
            })
            ->rawColumns(['is_taken', 'action'])
            ->setRowId('id');
    }

    public function query(Order $model): QueryBuilder
    {
        return $model->newQuery()->with(['campaign','user'])
            ->whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
            ->where('payment_status', 'paid')
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('distribution-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari buyer:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ pesanan'], 'responsive'=>true]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('user_name')->title('Buyer'),
            Column::make('campaign_title')->title('Campaign'),
            Column::make('total_quantity')->title('Qty')->width('80px'),
            Column::make('is_taken')->title('Status')->width('120px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('150px'),
        ];
    }

    protected function filename(): string { return 'Distribution_' . date('YmdHis'); }
}
