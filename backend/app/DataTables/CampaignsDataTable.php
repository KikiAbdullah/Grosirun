<?php
namespace App\DataTables;
use App\Models\Campaign;
use Illuminate\Database\Eloquent\Builder as QueryBuilder;
use Yajra\DataTables\EloquentDataTable;
use Yajra\DataTables\Html\Builder as HtmlBuilder;
use Yajra\DataTables\Html\Button;
use Yajra\DataTables\Html\Column;
use Yajra\DataTables\Services\DataTable;

class CampaignsDataTable extends DataTable
{
    public function dataTable(QueryBuilder $query): EloquentDataTable
    {
        return (new EloquentDataTable($query))
            ->addColumn('initiator_name', fn($c) => $c->initiator->name ?? '-')
            ->addColumn('progress', function($c) {
                $p = round($c->progressPercent * 100);
                $color = $p >= 70 ? 'warning' : 'primary';
                return "<div class='progress-bar'><div class='progress-bar-fill-{$color}' style='width:{$p}%'>{$p}%</div></div>";
            })
            ->addColumn('deadline_display', fn($c) => $c->deadline->diffForHumans())
            ->addColumn('price', fn($c) => 'Rp' . number_format($c->buyer_unit_price, 0, ',', '.') . '/' . $c->unit)
            ->editColumn('status', fn($c) => '<span class="badge badge-' . match($c->status){'active'=>'success','target_reached'=>'info','completed'=>'success','cancelled'=>'danger',default=>'neutral'} . '">' . ucfirst(str_replace('_', ' ', $c->status)) . '</span>')
            ->addColumn('action', function($c) {
                return '<div class="flex gap-2">'
                    . '<a href="' . route('campaigns.show', $c->uuid) . '" class="btn-icon" title="Detail"><i data-lucide="eye" class="w-4 h-4"></i></a>'
                    . '<a href="' . route('campaigns.edit', $c->uuid) . '" class="btn-icon" title="Edit"><i data-lucide="edit-2" class="w-4 h-4"></i></a>'
                    . '<a href="' . route('campaigns.recap', $c->uuid) . '" class="btn-icon" title="Recap"><i data-lucide="bar-chart-2" class="w-4 h-4"></i></a>'
                    . '</div>';
            })
            ->rawColumns(['progress', 'status', 'action'])
            ->setRowId('id');
    }

    public function query(Campaign $model): QueryBuilder
    {
        return $model->newQuery()->with(['initiator', 'cluster'])->latest();
    }

    public function html(): HtmlBuilder
    {
        return $this->builder()
            ->setTableId('campaigns-table')
            ->columns($this->getColumns())
            ->minifiedAjax()
            ->orderBy(0, 'desc')
            ->parameters([
                'language' => ['search' => 'Cari campaign:', 'lengthMenu' => 'Tampilkan _MENU_ data', 'info' => 'Menampilkan _START_-_END_ dari _TOTAL_ campaign', 'zeroRecords' => 'Tidak ada campaign ditemukan'],
                'responsive' => true,
            ])
            ->buttons([
                Button::make('print'),
                Button::make('reset'),
                Button::make('reload'),
            ]);
    }

    public function getColumns(): array
    {
        return [
            Column::make('title')->title('Judul')->searchable(true),
            Column::make('initiator_name')->title('Inisiator')->orderable(false),
            Column::make('progress')->title('Progress')->orderable(false)->width('120px'),
            Column::make('target_quantity')->title('Target')->width('80px'),
            Column::make('price')->title('Harga')->orderable(false),
            Column::make('deadline_display')->title('Deadline')->orderable(false),
            Column::make('status')->title('Status')->width('100px'),
            Column::computed('action')->title('Aksi')->orderable(false)->searchable(false)->width('120px'),
        ];
    }

    protected function filename(): string { return 'Campaigns_' . date('YmdHis'); }
}
