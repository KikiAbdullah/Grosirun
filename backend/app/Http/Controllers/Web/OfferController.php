<?php
namespace App\Http\Controllers\Web;
use App\DataTables\OffersDataTable;
use App\Http\Controllers\Controller;
use App\Models\{SupplierOffer,SupplierProduct};
use Illuminate\Http\Request;

class OfferController extends Controller
{
    public function index(OffersDataTable $dataTable) { return $dataTable->render('offers.index'); }
    public function create() { return view('offers.create', ['products'=>SupplierProduct::where('supplier_id',auth()->user()->supplier_id??1)->get()]); }
    public function store(Request $r)
    {
        $r->validate(['product_id'=>'required|exists:supplier_products,id','minimum_order'=>'required|integer|min:1','capacity'=>'required|integer|min:1','delivery_cost'=>'required|integer|min:0','valid_until'=>'required|date|after:today','service_areas'=>'required|array|min:1']);
        $p = SupplierProduct::findOrFail($r->product_id);
        SupplierOffer::create(['supplier_id'=>auth()->user()->supplier_id??1,'product_id'=>$r->product_id,'unit'=>$p->base_unit,'minimum_order'=>$r->minimum_order,'capacity'=>$r->capacity,'delivery_cost'=>$r->delivery_cost,'valid_until'=>$r->valid_until,'service_areas'=>$r->service_areas,'tiers'=>$r->tiers??[],'status'=>'pending_moderation']);
        return redirect()->route('offers.index')->with('success','Offer disubmit');
    }
    public function edit(int $id) { return view('offers.edit', ['offer'=>SupplierOffer::with('product')->findOrFail($id)]); }
    public function update(Request $r, int $id) { $r->validate(['minimum_order'=>'required|integer|min:1','capacity'=>'required|integer|min:1']); SupplierOffer::findOrFail($id)->update($r->only(['minimum_order','capacity','delivery_cost','valid_until','service_areas','tiers'])); return back()->with('success','Offer diperbarui'); }
    public function destroy(int $id) { SupplierOffer::findOrFail($id)->delete(); return back()->with('success','Offer dihapus'); }
    public function submit(int $id) { SupplierOffer::findOrFail($id)->update(['status'=>'pending_moderation']); return back()->with('success','Offer disubmit'); }
}
