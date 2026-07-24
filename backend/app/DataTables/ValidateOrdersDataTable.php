<?php
namespace App\DataTables;
use App\Models\Order;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class ValidateOrdersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('user_name', fn($o) => $o->user->name ?? '-')
            ->addColumn('campaign_title', fn($o) => $o->campaign->title ?? '-')
            ->editColumn('payment_method', fn($o) => strtoupper($o->payment_method))
            ->editColumn('total_price', fn($o) => 'Rp' . number_format($o->total_price, 0, ',', '.'))
            ->editColumn('payment_status', fn($o) => '<span class="badge badge-warning">' . ucfirst(str_replace('_',' ',$o->payment_status)) . '</span>')
            ->addColumn('action', function($o) {
                return '<div class="flex gap-2">'
                    . '<form method="POST" action="' . route('orders.validate-order', $o->uuid) . '"><input type="hidden" name="_token" value="' . csrf_token() . '"><button type="submit" class="btn btn-sm btn-primary">✓ Validasi</button></form>'
                    . '<form method="POST" action="' . route('orders.reject', $o->uuid) . '"><input type="hidden" name="_token" value="' . csrf_token() . '"><input type="hidden" name="reason" value="Bukti tidak jelas"><button type="submit" class="btn btn-sm btn-danger">✕ Tolak</button></form>'
                    . '</div>';
            })
            ->rawColumns(['payment_status', 'action'])
            ->setRowId('id');
    }

    public function query(Order $model): QueryBuilder
    {
        return $model->newQuery()->with(['campaign','user'])
            ->whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
            ->whereIn('payment_status', ['pending','waiting_qris'])
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('validate-orders-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari buyer:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ menunggu validasi'], 'responsive'=>true]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('user_name')->title('Buyer'),
            Column::make('campaign_title')->title('Campaign'),
            Column::make('payment_method')->title('Metode'),
            Column::make('total_price')->title('Total'),
            Column::make('payment_status')->title('Status')->width('120px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('200px'),
        ];
    }

    protected function filename(): string { return 'ValidateOrders_' . date('YmdHis'); }
}
