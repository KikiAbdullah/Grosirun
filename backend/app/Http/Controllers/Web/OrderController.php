<?php
namespace App\Http\Controllers\Web;
use App\DataTables\{OrdersDataTable, ValidateOrdersDataTable, DistributionDataTable};
use App\Http\Controllers\Controller;
use App\Models\Campaign;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function index(OrdersDataTable $dataTable) { return $dataTable->render('orders.index'); }

    public function store(Request $r)
    {
        $r->validate([
            'campaign_id'=>'required|integer|exists:campaigns,id',
            'variant_id'=>'required|integer|exists:campaign_variants,id',
            'quantity'=>'required|integer|min:1|max:100',
            'payment_method'=>'required|string|in:cash,qris',
        ]);
        $campaign = Campaign::findOrFail($r->campaign_id);
        $variant = $campaign->variants()->findOrFail($r->variant_id);
        Order::create([
            'uuid'=>Str::uuid(),'campaign_id'=>$campaign->id,'user_id'=>auth()->id(),
            'campaign_variant_id'=>$variant->id,'cluster_id'=>auth()->user()->cluster_id,
            'quantity'=>$r->quantity,'total_quantity'=>$r->quantity*$variant->quantity_per_variant,
            'total_price'=>$r->quantity*$variant->quantity_per_variant*$campaign->buyer_unit_price,
            'payment_method'=>$r->payment_method,
            'payment_status'=>$r->payment_method==='cash'?'pending':'waiting_qris',
            'idempotency_key'=>$r->header('Idempotency-Key')??Str::uuid(),
        ]);
        return back()->with('success','Pesanan berhasil dibuat');
    }

    public function show(string $uuid)
    {
        $order = Order::with(['campaign','variant','user'])->where('uuid',$uuid)->firstOrFail();
        abort_if($order->user_id!==auth()->id(),403);
        return view('orders.show', compact('order'));
    }

    public function destroy(string $uuid)
    {
        $o = Order::where('uuid',$uuid)->where('user_id',auth()->id())->firstOrFail();
        abort_if(!in_array($o->payment_status,['pending','waiting_qris']),403);
        $o->update(['payment_status'=>'cancelled']);
        return back()->with('success','Pesanan dibatalkan');
    }

    public function uploadProof(Request $r, string $uuid)
    {
        $r->validate(['proof'=>'required|file|mimes:jpg,jpeg,png|max:2048']);
        $o = Order::where('uuid',$uuid)->where('user_id',auth()->id())->firstOrFail();
        abort_if(!in_array($o->payment_status,['waiting_qris','rejected']),403);
        $path = $r->file('proof')->store('proofs/'.auth()->id(),'public');
        $o->update(['proof_path'=>$path,'proof_url'=>asset('storage/'.$path),'proof_uploaded_at'=>now(),'payment_status'=>'waiting_qris']);
        return back()->with('success','Bukti diupload');
    }

    public function markAsTaken(string $uuid)
    {
        Order::where('uuid',$uuid)->firstOrFail()->update(['is_taken'=>true,'taken_at'=>now(),'taken_by_initiator_id'=>auth()->id()]);
        return back()->with('success','Barang ditandai diambil');
    }

    public function validateIndex(ValidateOrdersDataTable $dataTable) { return $dataTable->render('orders.validate'); }

    public function validateOrder(Request $r, string $uuid)
    {
        $o = Order::where('uuid',$uuid)->firstOrFail();
        abort_if(!in_array($o->payment_status,['waiting_qris','pending']),409);
        $o->update(['payment_status'=>'paid']);
        return back()->with('success','Pembayaran divalidasi ✅');
    }

    public function rejectOrder(Request $r, string $uuid)
    {
        $r->validate(['reason'=>'required|string|max:500']);
        Order::where('uuid',$uuid)->firstOrFail()->update(['payment_status'=>'rejected','rejection_reason'=>$r->reason]);
        return back()->with('success','Pembayaran ditolak');
    }

    public function batchValidate(Request $r)
    {
        $r->validate(['order_ids'=>'required|array|min:1','order_ids.*'=>'integer']);
        $count = Order::whereIn('id',$r->order_ids)->whereHas('campaign',fn($q)=>$q->where('initiator_id',auth()->id()))->update(['payment_status'=>'paid']);
        return back()->with('success',"$count pesanan divalidasi");
    }
}
