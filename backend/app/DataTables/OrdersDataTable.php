<?php
namespace App\DataTables;
use App\Models\Order;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class OrdersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('campaign_title', fn($o) => $o->campaign->title ?? '-')
            ->editColumn('payment_method', fn($o) => '<span class="badge bg-secondary">'.strtoupper($o->payment_method).'</span>')
            ->editColumn('total_price', fn($o) => 'Rp'.number_format($o->total_price, 0, ',', '.'))
            ->editColumn('payment_status', fn($o) => '<span class="badge bg-'.match($o->payment_status){'paid'=>'success','pending'=>'warning','waiting_qris'=>'info','rejected'=>'danger',default=>'secondary'}.'">'.ucfirst(str_replace('_',' ',$o->payment_status)).'</span>')
            ->addColumn('action', fn($o) => '<a href="'.route('orders.show', $o->uuid).'" class="btn btn-sm btn-outline-primary"><i data-lucide="eye"></i></a>')
            ->rawColumns(['payment_method', 'total_price', 'payment_status', 'action'])
            ->setRowId('id');
    }

    public function query(Order $model): QueryBuilder
    {
        return $model->newQuery()
            ->select(['orders.*'])
            ->with(['campaign:id,title,uuid'])
            ->where('user_id', auth()->id())
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('orders-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari pesanan:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ pesanan'], 'responsive'=>true, 'pageLength'=>10])
            ->buttons([Button::make('print'), Button::make('reset'), Button::make('reload')]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('campaign_title')->title('Campaign'),
            Column::make('quantity')->title('Qty')->width('60px'),
            Column::make('payment_method')->title('Metode')->width('80px'),
            Column::make('total_price')->title('Total'),
            Column::make('payment_status')->title('Status')->width('120px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('60px'),
        ];
    }

    protected function filename(): string { return 'Orders_' . date('YmdHis'); }
}
