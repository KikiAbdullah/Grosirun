<?php
namespace App\Http\Controllers\Web;
use App\DataTables\CampaignsDataTable;
use App\Http\Controllers\Controller;
use App\Models\Campaign;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CampaignController extends Controller
{
    public function index(CampaignsDataTable $dataTable)
    {
        return $dataTable->render('campaigns.index');
    }

    public function create() { return view('campaigns.create'); }

    public function store(Request $r)
    {
        $r->validate([
            'title'=>'required|string|max:255','description'=>'nullable|string|max:2000',
            'target_quantity'=>'required|integer|min:1','unit'=>'required|string|in:kg,pcs,liter,butir',
            'buyer_unit_price'=>'required|integer|min:1','deadline_days'=>'required|integer|min:1|max:30',
            'location'=>'required|string|max:500',
        ]);
        Campaign::create([
            'uuid'=>Str::uuid(),'title'=>$r->title,'description'=>$r->description,'status'=>'active',
            'initiator_id'=>auth()->id(),'cluster_id'=>auth()->user()->cluster_id,
            'buyer_unit_price'=>$r->buyer_unit_price,'unit'=>$r->unit,
            'target_quantity'=>$r->target_quantity,'deadline'=>now()->addDays($r->deadline_days),
            'location_distribution'=>$r->location,
        ]);
        return redirect()->route('campaigns.index')->with('success','Campaign dipublikasikan');
    }

    public function show(string $uuid)
    {
        $campaign = Campaign::with(['initiator','cluster','variants'])->where('uuid',$uuid)->firstOrFail();
        return view('campaigns.show', compact('campaign'));
    }

    public function edit(string $uuid)
    {
        $campaign = Campaign::where('uuid',$uuid)->where('initiator_id',auth()->id())->firstOrFail();
        return view('campaigns.edit', compact('campaign'));
    }

    public function update(Request $r, string $uuid)
    {
        $r->validate(['title'=>'required|string|max:255','target_quantity'=>'required|integer|min:1']);
        Campaign::where('uuid',$uuid)->where('initiator_id',auth()->id())->firstOrFail()
            ->update($r->only(['title','target_quantity','buyer_unit_price','location_distribution']));
        return back()->with('success','Campaign diperbarui');
    }

    public function manage(CampaignsDataTable $dataTable)
    {
        return $dataTable->render('campaigns.manage');
    }

    public function extend(string $uuid)
    {
        $c = Campaign::where('uuid',$uuid)->where('initiator_id',auth()->id())->firstOrFail();
        abort_if(($c->extend_count??0)>=2,403,'Maksimal 2 perpanjangan');
        $c->update(['deadline'=>$c->deadline->addDays(2),'extend_count'=>($c->extend_count??0)+1]);
        return back()->with('success','Campaign diperpanjang 2 hari');
    }

    public function cancel(string $uuid)
    {
        Campaign::where('uuid',$uuid)->where('initiator_id',auth()->id())->firstOrFail()->update(['status'=>'cancelled']);
        return back()->with('success','Campaign dibatalkan');
    }

    public function complete(string $uuid)
    {
        Campaign::where('uuid',$uuid)->where('initiator_id',auth()->id())->firstOrFail()
            ->update(['status'=>'completed','distribution_completed_at'=>now()]);
        return back()->with('success','Distribusi selesai');
    }

    public function recap(string $uuid)
    {
        $campaign = Campaign::with(['variants','orders.user'])->where('uuid',$uuid)->firstOrFail();
        $orders = $campaign->orders()->where('payment_status','paid')->get();
        return view('campaigns.recap', compact('campaign','orders'));
    }
}
