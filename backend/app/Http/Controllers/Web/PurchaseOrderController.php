<?php
namespace App\Http\Controllers\Web;
use App\DataTables\PurchaseOrdersDataTable;
use App\Http\Controllers\Controller;
use App\Models\Campaign;
use App\Models\PurchaseOrder;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PurchaseOrderController extends Controller
{
    public function index(PurchaseOrdersDataTable $dataTable) { return $dataTable->render('purchase-orders.index'); }

    public function create() { return view('purchase-orders.create', ['campaigns'=>Campaign::where('initiator_id',auth()->id())->where('status','target_reached')->get()]); }

    public function store(Request $r)
    {
        $r->validate(['campaign_id'=>'required|exists:campaigns,id','supplier_id'=>'required|exists:suppliers,id','quantity'=>'required|integer|min:1','unit_price'=>'required|integer|min:1']);
        $po = PurchaseOrder::create([
            'uuid'=>Str::uuid(),'campaign_id'=>$r->campaign_id,'supplier_id'=>$r->supplier_id,
            'initiator_id'=>auth()->id(),'total_quantity'=>$r->quantity,'unit_price'=>$r->unit_price,
            'total_amount'=>($r->quantity*$r->unit_price)+200000,'status'=>'submitted',
        ]);
        return redirect()->route('purchase-orders.show',$po->uuid)->with('success','PO dibuat');
    }

    public function show(string $uuid) { return view('purchase-orders.show', ['po'=>PurchaseOrder::with(['campaign','supplier','initiator','documents'])->where('uuid',$uuid)->firstOrFail()]); }
    public function accept(string $uuid) { $po=PurchaseOrder::where('uuid',$uuid)->firstOrFail(); abort_if($po->status!=='submitted',409); $po->update(['status'=>'accepted','accepted_at'=>now()]); return back()->with('success','PO diterima'); }
    public function reject(Request $r, string $uuid) { $r->validate(['reason'=>'required|string|max:500']); $po=PurchaseOrder::where('uuid',$uuid)->firstOrFail(); abort_if($po->status!=='submitted',409); $po->update(['status'=>'rejected','rejected_reason'=>$r->reason,'rejected_at'=>now()]); return back()->with('success','PO ditolak'); }
    public function confirmPayment(string $uuid) { $po=PurchaseOrder::where('uuid',$uuid)->firstOrFail(); abort_if($po->status!=='accepted',409); $po->update(['status'=>'paid','payment_status'=>'confirmed']); return back()->with('success','Pembayaran dikonfirmasi'); }
    public function updateStatus(Request $r, string $uuid) { $r->validate(['status'=>'required|in:processing,shipped,completed']); PurchaseOrder::where('uuid',$uuid)->firstOrFail()->update(['status'=>$r->status]); return back()->with('success','Status: '.ucfirst($r->status)); }
    public function uploadDocument(Request $r, string $uuid)
    {
        $r->validate(['documents'=>'required','documents.*'=>'file|mimes:jpg,jpeg,png,pdf|max:5120']);
        $po = PurchaseOrder::where('uuid',$uuid)->firstOrFail();
        foreach($r->file('documents') as $f) { $path=$f->store('po-documents/'.$po->uuid,'public'); $po->documents()->create(['file_path'=>$path,'file_url'=>asset('storage/'.$path),'file_name'=>$f->getClientOriginalName(),'file_type'=>$f->getMimeType()]); }
        return back()->with('success','Dokumen diupload');
    }
}
