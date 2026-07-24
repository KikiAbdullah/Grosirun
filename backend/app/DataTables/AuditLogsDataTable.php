<?php
namespace App\DataTables;
use App\Models\TransactionLog;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class AuditLogsDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->editColumn('created_at', fn($l) => $l->created_at->format('d M Y, H:i'))
            ->editColumn('action', fn($l) => '<span class="badge badge-' . match(true){str_contains($l->action,'suspend')=>'danger',str_contains($l->action,'reject')=>'danger',str_contains($l->action,'verif')||str_contains($l->action,'approv')=>'success',str_contains($l->action,'resolved')=>'info',default=>'neutral'} . '">' . str_replace('_',' ',$l->action) . '</span>')
            ->addColumn('target', fn($l) => $l->target_type . ($l->target_id ? ' #' . $l->target_id : ''))
            ->addColumn('user_name', fn($l) => $l->user->name ?? $l->user_name ?? '-')
            ->rawColumns(['created_at', 'action'])
            ->setRowId('id');
    }

    public function query(TransactionLog $model): QueryBuilder { return $model->newQuery()->with('user')->latest(); }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('audit-logs-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari aksi/deskripsi:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ entri'], 'responsive'=>true])
            ->buttons([Button::make('print'), Button::make('reset'), Button::make('reload')]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('created_at')->title('Waktu')->width('150px'),
            Column::make('action')->title('Aksi'),
            Column::make('target')->title('Target')->orderable(false),
            Column::make('user_name')->title('Oleh')->orderable(false),
            Column::make('description')->title('Deskripsi'),
        ];
    }

    protected function filename(): string { return 'AuditLogs_' . date('YmdHis'); }
}
