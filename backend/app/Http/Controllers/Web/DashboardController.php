<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\{Campaign, Order, User, PurchaseOrder, Supplier, SupplierOffer, SupplierProduct};
use Illuminate\Support\Facades\Cache;

class DashboardController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        $role = session('active_role', $user->active_role ?? 'buyer');

        // Validasi khusus seller
        if ($role === 'seller' && is_null($user->supplier_id)) {
            return redirect()->route('supplier.setting')
                ->with('error', 'Anda belum memiliki data supplier, silakan lengkapi profil terlebih dahulu.');
        }

        // Key cache unik per user dan role
        $cacheKey = "dashboard_metrics_{$role}_" . $user->id;

        // Gunakan lock untuk mencegah stampede saat cache expired
        $metrics = Cache::lock($cacheKey . '_lock', 10)->block(5, function () use ($cacheKey, $role, $user) {
            return Cache::remember($cacheKey, 300, function () use ($role, $user) {
                return $this->fetchMetrics($role, $user);
            });
        });

        return view('dashboard.index', compact('metrics', 'role'));
    }

    /**
     * Mengambil metrik berdasarkan role dengan query efisien
     */
    private function fetchMetrics(string $role, $user): array
    {
        return match ($role) {
            'admin' => $this->getAdminMetrics(),
            'initiator' => $this->getInitiatorMetrics($user->id),
            'seller' => $this->getSellerMetrics($user->supplier_id),
            default => $this->getBuyerMetrics($user->id, $user->cluster_id),
        };
    }

    private function getAdminMetrics(): array
    {
        // Beberapa tabel berbeda, tetap perlu query terpisah, tapi sudah optimal
        return [
            'pending_suppliers' => Supplier::where('status', 'pending_verification')->count(),
            'pending_offers'    => SupplierOffer::where('status', 'pending_moderation')->count(),
            'open_disputes'     => PurchaseOrder::whereIn('status', ['disputed', 'rejected'])->count(),
            'active_campaigns'  => Campaign::where('status', 'active')->count(),
            'total_users'       => User::count(),
            'total_orders'      => Order::count(),
            'gmv_total'         => Order::where('payment_status', 'paid')->sum('total_price'),
            'today_orders'      => Order::whereDate('created_at', today())->count(),
        ];
    }

    private function getInitiatorMetrics(int $initiatorId): array
    {
        // Gabungkan query orders dengan conditional aggregates (satu kali scan)
        $orderStats = Order::whereHas('campaign', fn($q) => $q->where('initiator_id', $initiatorId))
            ->selectRaw("
                COUNT(*) as total_orders,
                SUM(CASE WHEN payment_status IN ('pending', 'waiting_qris') THEN 1 ELSE 0 END) as pending_validation,
                SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid_orders,
                SUM(CASE WHEN payment_status = 'paid' AND is_taken = false THEN 1 ELSE 0 END) as not_taken,
                SUM(CASE WHEN payment_status = 'paid' AND is_taken = true THEN 1 ELSE 0 END) as completed,
                SUM(CASE WHEN payment_status = 'paid' THEN total_price ELSE 0 END) as total_revenue
            ")->first();

        // Query terpisah untuk campaign aktif dan pending PO
        $activeCampaigns = Campaign::where('initiator_id', $initiatorId)
            ->where('status', 'active')->count();

        $pendingPos = PurchaseOrder::where('initiator_id', $initiatorId)
            ->whereIn('status', ['submitted', 'accepted'])->count();

        return [
            'active_campaigns'  => $activeCampaigns,
            'pending_validation' => $orderStats->pending_validation ?? 0,
            'total_orders'      => $orderStats->total_orders ?? 0,
            'paid_orders'       => $orderStats->paid_orders ?? 0,
            'pending_pos'       => $pendingPos,
            'total_revenue'     => $orderStats->total_revenue ?? 0,
            'not_taken'         => $orderStats->not_taken ?? 0,
            'completed'         => $orderStats->completed ?? 0,
        ];
    }

    private function getSellerMetrics(int $supplierId): array
    {
        // Gabungkan query PurchaseOrder (satu kali scan)
        $poStats = PurchaseOrder::where('supplier_id', $supplierId)
            ->selectRaw("
                COUNT(*) as total_po,
                SUM(CASE WHEN status = 'submitted' THEN 1 ELSE 0 END) as pending_pos,
                SUM(CASE WHEN status IN ('accepted', 'paid', 'processing') THEN 1 ELSE 0 END) as processing_pos,
                SUM(CASE WHEN status IN ('paid', 'processing', 'shipped', 'completed') THEN total_amount ELSE 0 END) as total_revenue,
                SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_pos
            ")->first();

        $totalProducts = SupplierProduct::where('supplier_id', $supplierId)->count();
        $activeOffers = SupplierOffer::where('supplier_id', $supplierId)
            ->where('status', 'active')->count();

        return [
            'total_products'    => $totalProducts,
            'active_offers'     => $activeOffers,
            'pending_pos'       => $poStats->pending_pos ?? 0,
            'processing_pos'    => $poStats->processing_pos ?? 0,
            'total_revenue'     => $poStats->total_revenue ?? 0,
            'completed_pos'     => $poStats->completed_pos ?? 0,
        ];
    }

    private function getBuyerMetrics(int $userId, ?int $clusterId): array
    {
        // Gabungkan query Order milik user
        $orderStats = Order::where('user_id', $userId)
            ->selectRaw("
                COUNT(*) as my_orders,
                SUM(CASE WHEN payment_status IN ('pending', 'waiting_qris') THEN 1 ELSE 0 END) as pending_payment,
                SUM(CASE WHEN payment_status = 'paid' THEN 1 ELSE 0 END) as paid_orders,
                SUM(CASE WHEN payment_status = 'paid' AND is_taken = false THEN 1 ELSE 0 END) as not_taken,
                SUM(CASE WHEN payment_status = 'paid' AND is_taken = true THEN 1 ELSE 0 END) as taken,
                SUM(CASE WHEN payment_status = 'paid' THEN total_price ELSE 0 END) as total_spent
            ")->first();

        // Campaign aktif di cluster user
        $activeCampaigns = Campaign::where('status', 'active')
            ->when($clusterId, fn($q) => $q->where('cluster_id', $clusterId))
            ->count();

        return [
            'active_campaigns'  => $activeCampaigns,
            'my_orders'         => $orderStats->my_orders ?? 0,
            'pending_payment'   => $orderStats->pending_payment ?? 0,
            'paid_orders'       => $orderStats->paid_orders ?? 0,
            'total_spent'       => $orderStats->total_spent ?? 0,
            'not_taken'         => $orderStats->not_taken ?? 0,
            'taken'             => $orderStats->taken ?? 0,
        ];
    }
}
