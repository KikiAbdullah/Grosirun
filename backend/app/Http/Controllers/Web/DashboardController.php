<?php
namespace App\Http\Controllers\Web;
use App\Http\Controllers\Controller;
use App\Models\{Campaign,Order,User,PurchaseOrder,Supplier,SupplierOffer};
use Illuminate\Support\Facades\Cache;

class DashboardController extends Controller
{
    public function index()
    {
        $role = session('active_role', auth()->user()->active_role ?? 'buyer');
        
        $metrics = Cache::remember("dashboard_metrics_{$role}_".auth()->id(), 300, function () use ($role) {
            return match ($role) {
                'admin' => [
                    'pending_suppliers' => Supplier::where('status', 'pending_verification')->count(),
                    'pending_offers'    => SupplierOffer::where('status', 'pending_moderation')->count(),
                    'open_disputes'     => PurchaseOrder::whereIn('status', ['disputed', 'rejected'])->count(),
                    'active_campaigns'  => Campaign::where('status', 'active')->count(),
                    'total_users'       => User::count(),
                    'total_orders'      => Order::count(),
                    'gmv_total'         => Order::where('payment_status', 'paid')->sum('total_price'),
                    'today_orders'      => Order::whereDate('created_at', today())->count(),
                ],
                'initiator' => [
                    'active_campaigns'  => Campaign::where('initiator_id', auth()->id())->where('status', 'active')->count(),
                    'pending_validation'=> Order::whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
                                             ->whereIn('payment_status', ['pending', 'waiting_qris'])->count(),
                    'total_orders'      => Order::whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))->count(),
                    'paid_orders'       => Order::whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
                                             ->where('payment_status', 'paid')->count(),
                    'pending_pos'       => PurchaseOrder::where('initiator_id', auth()->id())
                                             ->whereIn('status', ['submitted', 'accepted'])->count(),
                    'total_revenue'     => Order::whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
                                             ->where('payment_status', 'paid')->sum('total_price'),
                    'not_taken'         => Order::whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
                                             ->where('payment_status', 'paid')->where('is_taken', false)->count(),
                    'completed'         => Order::whereHas('campaign', fn($q) => $q->where('initiator_id', auth()->id()))
                                             ->where('is_taken', true)->count(),
                ],
                'seller' => [
                    'total_products'    => \App\Models\SupplierProduct::where('supplier_id', auth()->user()->supplier_id ?? 1)->count(),
                    'active_offers'     => SupplierOffer::where('supplier_id', auth()->user()->supplier_id ?? 1)
                                             ->where('status', 'active')->count(),
                    'pending_pos'       => PurchaseOrder::where('supplier_id', auth()->user()->supplier_id ?? 1)
                                             ->where('status', 'submitted')->count(),
                    'processing_pos'    => PurchaseOrder::where('supplier_id', auth()->user()->supplier_id ?? 1)
                                             ->whereIn('status', ['accepted', 'paid', 'processing'])->count(),
                    'total_revenue'     => PurchaseOrder::where('supplier_id', auth()->user()->supplier_id ?? 1)
                                             ->whereIn('status', ['paid', 'processing', 'shipped', 'completed'])->sum('total_amount'),
                    'completed_pos'     => PurchaseOrder::where('supplier_id', auth()->user()->supplier_id ?? 1)
                                             ->where('status', 'completed')->count(),
                ],
                default => [ // buyer
                    'active_campaigns'  => Campaign::where('status', 'active')
                                             ->where('cluster_id', auth()->user()->cluster_id)->count(),
                    'my_orders'         => Order::where('user_id', auth()->id())->count(),
                    'pending_payment'   => Order::where('user_id', auth()->id())
                                             ->whereIn('payment_status', ['pending', 'waiting_qris'])->count(),
                    'paid_orders'       => Order::where('user_id', auth()->id())
                                             ->where('payment_status', 'paid')->count(),
                    'total_spent'       => Order::where('user_id', auth()->id())
                                             ->where('payment_status', 'paid')->sum('total_price'),
                    'not_taken'         => Order::where('user_id', auth()->id())
                                             ->where('payment_status', 'paid')->where('is_taken', false)->count(),
                    'taken'             => Order::where('user_id', auth()->id())
                                             ->where('is_taken', true)->count(),
                ],
            };
        });

        return view('dashboard.index', compact('metrics', 'role'));
    }
}
