<?php
namespace App\DataTables;
use App\Models\PurchaseOrder;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class PurchaseOrdersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('campaign_title', fn($po) => $po->campaign->title ?? '-')
            ->addColumn('supplier_name', fn($po) => $po->supplier->name ?? '-')
            ->editColumn('total_amount', fn($po) => 'Rp'.number_format($po->total_amount, 0, ',', '.'))
            ->editColumn('status', fn($po) => '<span class="badge bg-'.match($po->status){'submitted'=>'warning','accepted'=>'info','paid'=>'success','processing'=>'info','shipped'=>'info','completed'=>'success','rejected'=>'danger',default=>'secondary'}.'">'.ucfirst($po->status).'</span>')
            ->addColumn('action', fn($po) => '<a href="'.route('purchase-orders.show', $po->uuid).'" class="btn btn-sm btn-outline-primary"><i data-lucide="eye"></i></a>')
            ->rawColumns(['total_amount', 'status', 'action'])
            ->setRowId('id');
    }

    public function query(PurchaseOrder $model): QueryBuilder
    {
        $q = $model->newQuery()
            ->select(['purchase_orders.*'])
            ->with(['campaign:id,title,uuid', 'supplier:id,name', 'initiator:id,name']);
        
        $role = session('active_role', auth()->user()->active_role ?? 'buyer');
        if ($role === 'seller') $q->where('supplier_id', auth()->user()->supplier_id ?? 1);
        else $q->where('initiator_id', auth()->id());
        
        return $q->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('pos-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari PO:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ PO'], 'responsive'=>true, 'pageLength'=>10])
            ->buttons([Button::make('print'), Button::make('reset'), Button::make('reload')]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('campaign_title')->title('Campaign'),
            Column::make('supplier_name')->title('Supplier'),
            Column::make('total_quantity')->title('Qty')->width('80px'),
            Column::make('total_amount')->title('Total'),
            Column::make('status')->title('Status')->width('120px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('60px'),
        ];
    }

    protected function filename(): string { return 'POs_' . date('YmdHis'); }
}
