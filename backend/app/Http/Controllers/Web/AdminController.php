<?php
namespace App\Http\Controllers\Web;
use App\DataTables\{AdminUsersDataTable, AuditLogsDataTable, PendingSuppliersDataTable, ModerateOffersDataTable, DisputesDataTable};
use App\Http\Controllers\Controller;
use App\Models\{Supplier,SupplierOffer,User,PurchaseOrder,Campaign,TransactionLog};
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function dashboard()
    {
        return view('admin.dashboard', ['metrics'=>[
            'pending_suppliers'=>Supplier::where('status','pending_verification')->count(),
            'pending_offers'=>SupplierOffer::where('status','pending_moderation')->count(),
            'open_disputes'=>PurchaseOrder::whereIn('status',['disputed','rejected'])->count(),
            'active_campaigns'=>Campaign::where('status','active')->count(),
            'total_users'=>User::count(),
        ]]);
    }

    public function pendingSuppliers(PendingSuppliersDataTable $dataTable) { return $dataTable->render('admin.suppliers.pending'); }
    public function verifySupplier(Request $r, int $id)
    {
        $r->validate(['action'=>'required|in:approve,reject','reason'=>'nullable|string|max:500']);
        $s = Supplier::findOrFail($id);
        $s->update($r->action==='approve' ? ['status'=>'verified','verified_at'=>now()] : ['status'=>'rejected','rejection_reason'=>$r->reason]);
        return back()->with('success',$r->action==='approve'?'Supplier diverifikasi ✅':'Supplier ditolak');
    }

    public function moderateOffers(ModerateOffersDataTable $dataTable) { return $dataTable->render('admin.offers.moderate'); }
    public function moderateOffer(Request $r, int $id)
    {
        $r->validate(['action'=>'required|in:approve,reject','note'=>'nullable|string']);
        SupplierOffer::findOrFail($id)->update(['status'=>$r->action==='approve'?'active':'rejected','moderation_note'=>$r->note]);
        return back()->with('success',$r->action==='approve'?'Offer disetujui ✅':'Offer ditolak');
    }

    public function users(AdminUsersDataTable $dataTable) { return $dataTable->render('admin.users.index'); }
    public function manageRoles(Request $r, int $id) { $r->validate(['role'=>'required|in:buyer,initiator,seller,admin']); User::findOrFail($id)->assignRole($r->role); return back()->with('success','Role '.$r->role.' diberikan'); }
    public function suspendUser(Request $r, int $id) { $r->validate(['reason'=>'required|string|max:500']); User::findOrFail($id)->update(['suspended_at'=>now(),'suspension_reason'=>$r->reason]); return back()->with('success','User ditangguhkan'); }
    public function unsuspendUser(int $id) { User::findOrFail($id)->update(['suspended_at'=>null,'suspension_reason'=>null]); return back()->with('success','User diaktifkan'); }

    public function auditLogs(AuditLogsDataTable $dataTable) { return $dataTable->render('admin.audit-logs'); }

    public function disputes(DisputesDataTable $dataTable) { return $dataTable->render('admin.disputes.index'); }
    public function showDispute(int $id) { return view('admin.disputes.show', ['dispute'=>PurchaseOrder::with(['initiator','supplier','documents'])->findOrFail($id)]); }
    public function resolveDispute(Request $r, int $id)
    {
        $r->validate(['resolution'=>'required|in:replacement,refund,none','notes'=>'nullable|string|max:1000','refund_amount'=>'nullable|integer|min:0']);
        PurchaseOrder::findOrFail($id)->update(['status'=>'resolved','rejected_reason'=>$r->notes]);
        TransactionLog::create(['user_id'=>auth()->id(),'action'=>'dispute_resolved','target_type'=>'purchase_order','target_id'=>$id,'description'=>'Dispute diselesaikan: '.$r->resolution,'metadata'=>['resolution'=>$r->resolution,'refund'=>$r->refund_amount]]);
        return back()->with('success','Dispute diselesaikan: '.ucfirst($r->resolution));
    }
}
