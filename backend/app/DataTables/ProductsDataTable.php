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
            ->addColumn('variants_count', fn($p) => $p->variants->count() . ' varian')
            ->editColumn('base_unit', fn($p) => strtoupper($p->base_unit))
            ->addColumn('action', function($p) {
                return '<div class="flex gap-2">'
                    . '<a href="' . route('products.edit', $p->id) . '" class="btn-icon"><i data-lucide="edit-2" class="w-4 h-4"></i></a>'
                    . '<form method="POST" action="' . route('products.destroy', $p->id) . '" class="inline"><input type="hidden" name="_token" value="' . csrf_token() . '"><input type="hidden" name="_method" value="DELETE"><button type="submit" class="btn-icon text-danger-600" onclick="return confirm(\'Hapus produk?\')"><i data-lucide="trash-2" class="w-4 h-4"></i></button></form>'
                    . '</div>';
            })
            ->rawColumns(['action'])
            ->setRowId('id');
    }

    public function query(SupplierProduct $model): QueryBuilder
    {
        return $model->newQuery()->with('variants')->where('supplier_id', auth()->user()->supplier_id ?? 1)->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('products-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari produk:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ produk'], 'responsive'=>true])
            ->buttons([Button::make('print'), Button::make('reset'), Button::make('reload')]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('name')->title('Nama Produk'),
            Column::make('base_unit')->title('Unit')->width('80px'),
            Column::make('variants_count')->title('Varian')->orderable(false)->width('100px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('100px'),
        ];
    }

    protected function filename(): string { return 'Products_' . date('YmdHis'); }
}
