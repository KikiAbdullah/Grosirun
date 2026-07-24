<?php
namespace App\Http\Controllers\Web;
use App\DataTables\DistributionDataTable;
use App\Http\Controllers\Controller;

class DistributionController extends Controller
{
    public function index(DistributionDataTable $dataTable) { return $dataTable->render('distribution.index'); }
}
