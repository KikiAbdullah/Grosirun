<?php
namespace App\DataTables;
use App\Models\PurchaseOrder;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class DisputesDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('campaign_title', fn($po) => $po->campaign->title ?? 'PO #'.$po->id)
            ->addColumn('initiator_name', fn($po) => $po->initiator->name ?? '-')
            ->addColumn('supplier_name', fn($po) => $po->supplier->name ?? '-')
            ->editColumn('total_amount', fn($po) => 'Rp'.number_format($po->total_amount, 0, ',', '.'))
            ->editColumn('status', fn($po) => '<span class="badge bg-'.($po->status === 'rejected' ? 'danger' : 'warning').'">'.ucfirst($po->status).'</span>')
            ->editColumn('created_at', fn($po) => $po->created_at->diffForHumans())
            ->addColumn('action', fn($po) => '<a href="'.route('admin.disputes.show', $po->id).'" class="btn btn-sm btn-primary"><i data-lucide="eye"></i> Detail</a>')
            ->rawColumns(['total_amount', 'status', 'action'])
            ->setRowId('id');
    }

    public function query(PurchaseOrder $model): QueryBuilder
    {
        return $model->newQuery()
            ->select(['purchase_orders.*'])
            ->with(['campaign:id,title', 'initiator:id,name', 'supplier:id,name'])
            ->whereIn('status', ['disputed','rejected'])
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('disputes-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari dispute:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ dispute'], 'responsive'=>true, 'pageLength'=>10]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('created_at')->title('Waktu')->width('120px'),
            Column::make('campaign_title')->title('Campaign/PO'),
            Column::make('initiator_name')->title('Inisiator'),
            Column::make('supplier_name')->title('Supplier'),
            Column::make('total_amount')->title('Total'),
            Column::make('status')->title('Status')->width('100px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('100px'),
        ];
    }

    protected function filename(): string { return 'Disputes_' . date('YmdHis'); }
}
