<?php
namespace App\DataTables;
use App\Models\SupplierProduct;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class ProductsDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('variants_count', fn($p) => $p->variants->count().' varian')
            ->editColumn('base_unit', fn($p) => strtoupper($p->base_unit))
            ->addColumn('action', function($p) {
                return '<div class="btn-group btn-group-sm">'
                    .'<a href="'.route('products.edit', $p->id).'" class="btn btn-outline-primary"><i data-lucide="edit-2"></i></a>'
                    .'<form method="POST" action="'.route('products.destroy', $p->id).'" class="d-inline">'.csrf_field().method_field('DELETE').'<button type="submit" class="btn btn-outline-danger" onclick="return confirm(\'Hapus?\')"><i data-lucide="trash-2"></i></button></form>'
                    .'</div>';
            })
            ->rawColumns(['action'])
            ->setRowId('id');
    }

    public function query(SupplierProduct $model): QueryBuilder
    {
        return $model->newQuery()
            ->select(['supplier_products.*'])
            ->withCount('variants')
            ->where('supplier_id', auth()->user()->supplier_id ?? 1)
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('products-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari produk:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ produk'], 'responsive'=>true, 'pageLength'=>10])
            ->buttons([Button::make('print'), Button::make('reset'), Button::make('reload')]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('name')->title('Nama Produk'),
            Column::make('base_unit')->title('Unit')->width('80px'),
            Column::make('variants_count')->title('Varian')->width('100px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('100px'),
        ];
    }

    protected function filename(): string { return 'Products_' . date('YmdHis'); }
}
