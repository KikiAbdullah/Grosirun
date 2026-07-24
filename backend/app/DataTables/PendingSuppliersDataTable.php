<?php
namespace App\DataTables;
use App\Models\Supplier;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class PendingSuppliersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->editColumn('created_at', fn($s) => $s->created_at->diffForHumans())
            ->addColumn('action', function($s) {
                return '<div class="btn-group btn-group-sm">'
                    .'<form method="POST" action="'.route('admin.suppliers.verify', $s->id).'" class="d-inline">'.csrf_field().'<input type="hidden" name="action" value="approve"><button type="submit" class="btn btn-success"><i data-lucide="shield-check"></i> Approve</button></form>'
                    .'<form method="POST" action="'.route('admin.suppliers.verify', $s->id).'" class="d-inline">'.csrf_field().'<input type="hidden" name="action" value="reject"><input type="hidden" name="reason" value=""><button type="button" class="btn btn-danger reject-btn" data-id="'.$s->id.'"><i data-lucide="x"></i> Reject</button></form>'
                    .'</div>';
            })
            ->rawColumns(['action'])
            ->setRowId('id');
    }

    public function query(Supplier $model): QueryBuilder
    {
        return $model->newQuery()
            ->select(['suppliers.*'])
            ->where('status', 'pending_verification')
            ->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('suppliers-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari supplier:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ supplier'], 'responsive'=>true, 'pageLength'=>10]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('created_at')->title('Mendaftar')->width('120px'),
            Column::make('name')->title('Nama Supplier'),
            Column::make('siup')->title('SIUP')->searchable(false),
            Column::make('contact_phone')->title('Kontak'),
            Column::make('contact_email')->title('Email'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('200px'),
        ];
    }

    protected function filename(): string { return 'Suppliers_' . date('YmdHis'); }
}
