<?php
namespace App\Http\Controllers\Web;
use App\DataTables\ProductsDataTable;
use App\Http\Controllers\Controller;
use App\Models\SupplierProduct;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(ProductsDataTable $dataTable) { return $dataTable->render('products.index'); }
    public function create() { return view('products.create'); }
    public function store(Request $r)
    {
        $r->validate(['name'=>'required|string|max:255','description'=>'nullable|string|max:2000','base_unit'=>'required|string|in:kg,pcs,liter,pack,dus','image'=>'nullable|image|mimes:jpg,jpeg,png|max:5120']);
        $data = $r->only(['name','description','base_unit']);
        $data['supplier_id'] = auth()->user()->supplier_id ?? 1;
        if ($r->hasFile('image')) $data['image_url'] = $r->file('image')->store('products','public');
        SupplierProduct::create($data);
        return redirect()->route('products.index')->with('success','Produk dibuat');
    }
    public function edit(int $id) { return view('products.edit', ['product'=>SupplierProduct::with('variants')->findOrFail($id)]); }
    public function update(Request $r, int $id) { $r->validate(['name'=>'required|string|max:255','base_unit'=>'required|string']); SupplierProduct::findOrFail($id)->update($r->only(['name','description','base_unit'])); return back()->with('success','Produk diperbarui'); }
    public function destroy(int $id) { SupplierProduct::findOrFail($id)->delete(); return back()->with('success','Produk dihapus'); }
}
