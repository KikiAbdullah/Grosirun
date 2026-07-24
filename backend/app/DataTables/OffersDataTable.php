<?php
namespace App\DataTables;
use App\Models\SupplierOffer;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class OffersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('product_name', fn($o) => $o->product->name ?? '-')
            ->editColumn('status', fn($o) => '<span class="badge badge-' . match($o->status){'active'=>'success','draft'=>'neutral','pending_moderation'=>'warning','expired'=>'neutral','rejected'=>'danger',default=>'neutral'} . '">' . ucfirst(str_replace('_',' ',$o->status)) . '</span>')
            ->editColumn('valid_until', fn($o) => $o->valid_until->format('d M Y'))
            ->addColumn('action', function($o) {
                return '<div class="flex gap-2">'
                    . '<a href="' . route('offers.edit', $o->id) . '" class="btn-icon"><i data-lucide="edit-2" class="w-4 h-4"></i></a>'
                    . '</div>';
            })
            ->rawColumns(['status', 'action'])
            ->setRowId('id');
    }

    public function query(SupplierOffer $model): QueryBuilder
    {
        return $model->newQuery()->with('product')->where('supplier_id', auth()->user()->supplier_id ?? 1)->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('offers-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari offer:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ offer'], 'responsive'=>true]);
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
