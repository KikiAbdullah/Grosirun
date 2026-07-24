<?php
namespace App\DataTables;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class AdminUsersDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->editColumn('active_role', fn($u) => '<span class="badge badge-info">' . ucfirst($u->active_role ?? 'buyer') . '</span>')
            ->editColumn('suspended_at', fn($u) => $u->suspended_at ? '<span class="badge badge-danger">Suspended</span>' : '<span class="badge badge-success">Aktif</span>')
            ->addColumn('action', function($u) {
                return '<form method="POST" action="' . route('admin.users.roles', $u->id) . '" class="inline">'
                    . '<input type="hidden" name="_token" value="' . csrf_token() . '">'
                    . '<select name="role" onchange="this.form.submit()" class="form-select py-1 text-xs"><option value="">+Role</option><option value="buyer">Buyer</option><option value="initiator">Initiator</option><option value="seller">Seller</option><option value="admin">Admin</option></select>'
                    . '</form>';
            })
            ->rawColumns(['active_role', 'suspended_at', 'action'])
            ->setRowId('id');
    }

    public function query(User $model): QueryBuilder { return $model->newQuery()->latest(); }

    public function html(): HtmlBuilder
    {
        return $this->builder()->setTableId('admin-users-table')->columns($this->getColumns())
            ->minifiedAjax()->orderBy(0, 'desc')
            ->parameters(['language'=>['search'=>'Cari nama/phone:','lengthMenu'=>'Tampilkan _MENU_','info'=>'_START_-_END_ dari _TOTAL_ user'], 'responsive'=>true]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('name')->title('Nama'),
            Column::make('phone_number')->title('WhatsApp'),
            Column::make('active_role')->title('Role')->width('100px'),
            Column::make('suspended_at')->title('Status')->width('100px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('120px'),
        ];
    }

    protected function filename(): string { return 'Users_' . date('YmdHis'); }
}
