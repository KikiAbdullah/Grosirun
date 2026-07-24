<?php
namespace App\DataTables;
use App\Models\SupplierOffer;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class OffersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('product_name', fn($o) => $o->product->name ?? '-')
            ->editColumn('status', fn($o) => '<span class="badge bg-'.match($o->status){'active'=>'success','draft'=>'secondary','pending_moderation'=>'warning','expired'=>'dark','rejected'=>'danger',default=>'secondary'}.'">'.ucfirst(str_replace('_',' ',$o->status)).'</span>')
            ->editColumn('valid_until', fn($o) => $o->valid_until?->format('d M Y') ?? '-')
            ->addColumn('action', fn($o) => '<a href="'.route('offers.edit', $o->id).'" class="btn btn-sm btn-outline-primary"><i data-lucide="edit-2"></i></a>')
            ->rawColumns(['status', 'action'])
            ->setRowId('id');
    }

    public function query(SupplierOffer $model): QueryBuilder
    {
        return $model->newQuery()
            ->select(['supplier_offers.*'])
            ->with(['product:id,name'])
            ->where('supplier_id', auth()->user()->supplier_id ?? 1)
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('offers-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari offer:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ offer'], 'responsive'=>true, 'pageLength'=>10]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('product_name')->title('Produk'),
            Column::make('minimum_order')->title('Min. Order'),
            Column::make('capacity')->title('Kapasitas'),
            Column::make('valid_until')->title('Berlaku s/d'),
            Column::make('status')->title('Status')->width('120px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('60px'),
        ];
    }

    protected function filename(): string { return 'Offers_' . date('YmdHis'); }
}
