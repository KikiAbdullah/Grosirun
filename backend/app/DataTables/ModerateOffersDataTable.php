<?php
namespace App\DataTables;
use App\Models\SupplierOffer;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class ModerateOffersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('product_name', fn($o) => $o->product->name ?? '-')
            ->addColumn('supplier_name', fn($o) => $o->supplier->name ?? '-')
            ->addColumn('action', function($o) {
                return '<div class="btn-group btn-group-sm">'
                    .'<form method="POST" action="'.route('admin.offers.moderate-action', $o->id).'" class="d-inline">'.csrf_field().'<input type="hidden" name="action" value="approve"><button type="submit" class="btn btn-success"><i data-lucide="check"></i> Approve</button></form>'
                    .'<form method="POST" action="'.route('admin.offers.moderate-action', $o->id).'" class="d-inline">'.csrf_field().'<input type="hidden" name="action" value="reject"><button type="submit" class="btn btn-danger"><i data-lucide="x"></i> Reject</button></form>'
                    .'</div>';
            })
            ->rawColumns(['action'])
            ->setRowId('id');
    }

    public function query(SupplierOffer $model): QueryBuilder
    {
        return $model->newQuery()
            ->select(['supplier_offers.*'])
            ->with(['product:id,name', 'supplier:id,name'])
            ->where('status', 'pending_moderation')
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('moderate-offers-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari offer:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ offer'], 'responsive'=>true, 'pageLength'=>10]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('product_name')->title('Produk'),
            Column::make('supplier_name')->title('Supplier'),
            Column::make('unit')->title('Unit')->width('60px'),
            Column::make('minimum_order')->title('Min. Order'),
            Column::make('capacity')->title('Kapasitas'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('200px'),
        ];
    }

    protected function filename(): string { return 'ModerateOffers_' . date('YmdHis'); }
}
