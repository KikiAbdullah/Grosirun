<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\Campaign;
use App\Models\CampaignVariant;
use App\Models\User;
use Illuminate\Support\Str;

class OrderSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $buyers = User::role('buyer')->get();
        $initiators = User::role('initiator')->get();
        
        // Orders for Campaign 1 (Active - Beras)
        $campaign1 = Campaign::where('title', 'Patungan Beras Premium Pulen')->first();
        $variant1 = CampaignVariant::where('campaign_id', $campaign1->id)->where('name', '5 Kg')->first();
        $variant2 = CampaignVariant::where('campaign_id', $campaign1->id)->where('name', '10 Kg')->first();
        
        // Pending orders (Tunai)
        Order::create([
            'uuid' => Str::uuid(),
            'campaign_id' => $campaign1->id,
            'user_id' => $buyers[0]->id,
            'campaign_variant_id' => $variant1->id,
            'cluster_id' => $campaign1->cluster_id,
            'quantity' => 1,
            'total_quantity' => 5,
            'total_price' => 60000,
            'payment_method' => 'cash',
            'payment_status' => 'pending',
            'idempotency_key' => Str::uuid(),
        ]);

        Order::create([
            'uuid' => Str::uuid(),
            'campaign_id' => $campaign1->id,
            'user_id' => $buyers[1]->id,
            'campaign_variant_id' => $variant2->id,
            'cluster_id' => $campaign1->cluster_id,
            'quantity' => 1,
            'total_quantity' => 10,
            'total_price' => 120000,
            'payment_method' => 'cash',
            'payment_status' => 'pending',
            'idempotency_key' => Str::uuid(),
        ]);

        // Waiting QRIS orders
        Order::create([
            'uuid' => Str::uuid(),
            'campaign_id' => $campaign1->id,
            'user_id' => $buyers[2]->id,
            'campaign_variant_id' => $variant1->id,
            'cluster_id' => $campaign1->cluster_id,
            'quantity' => 1,
            'total_quantity' => 5,
            'total_price' => 60000,
            'payment_method' => 'qris',
            'payment_status' => 'waiting_qris',
            'proof_path' => 'order_proofs/' . Str::uuid() . '.jpg',
            'idempotency_key' => Str::uuid(),
        ]);

        Order::create([
            'uuid' => Str::uuid(),
            'campaign_id' => $campaign1->id,
            'user_id' => $buyers[3]->id,
            'campaign_variant_id' => $variant1->id,
            'cluster_id' => $campaign1->cluster_id,
            'quantity' => 2,
            'total_quantity' => 10,
            'total_price' => 120000,
            'payment_method' => 'qris',
            'payment_status' => 'waiting_qris',
            'proof_path' => 'order_proofs/' . Str::uuid() . '.jpg',
            'idempotency_key' => Str::uuid(),
        ]);

        // Paid orders
        for ($i = 0; $i < 15; $i++) {
            $buyer = $buyers[$i % $buyers->count()];
            $variant = $i % 2 == 0 ? $variant1 : $variant2;
            $qty = $variant->name == '5 Kg' ? 1 : 1;
            
            Order::create([
                'uuid' => Str::uuid(),
                'campaign_id' => $campaign1->id,
                'user_id' => $buyer->id,
                'campaign_variant_id' => $variant->id,
                'cluster_id' => $campaign1->cluster_id,
                'quantity' => $qty,
                'total_quantity' => $variant->package_quantity,
                'total_price' => $qty * $variant->package_quantity * $campaign1->buyer_unit_price,
                'payment_method' => $i % 2 == 0 ? 'cash' : 'qris',
                'payment_status' => 'paid',
                'proof_path' => $i % 2 == 1 ? 'order_proofs/' . Str::uuid() . '.jpg' : null,
                'validation_notes' => 'Pembayaran diterima',
                'idempotency_key' => Str::uuid(),
            ]);
        }

        // Orders for Campaign 2 (Active - Minyak)
        $campaign2 = Campaign::where('title', 'Patungan Minyak Goreng 2L')->first();
        $variant3 = CampaignVariant::where('campaign_id', $campaign2->id)->where('name', '2 Liter')->first();
        
        for ($i = 0; $i < 20; $i++) {
            $buyer = $buyers[$i % $buyers->count()];
            
            Order::create([
                'uuid' => Str::uuid(),
                'campaign_id' => $campaign2->id,
                'user_id' => $buyer->id,
                'campaign_variant_id' => $variant3->id,
                'cluster_id' => $campaign2->cluster_id,
                'quantity' => 1,
                'total_quantity' => 2,
                'total_price' => 64000,
                'payment_method' => $i % 3 == 0 ? 'cash' : 'qris',
                'payment_status' => $i < 15 ? 'paid' : ($i < 18 ? 'pending' : 'waiting_qris'),
                'idempotency_key' => Str::uuid(),
            ]);
        }

        // Orders for Campaign 3 (Target Reached - Gula)
        $campaign3 = Campaign::where('title', 'Patungan Gula Pasir Putih')->first();
        $variant4 = CampaignVariant::where('campaign_id', $campaign3->id)->where('name', '1 Kg')->first();
        $variant5 = CampaignVariant::where('campaign_id', $campaign3->id)->where('name', '5 Kg')->first();
        
        for ($i = 0; $i < 25; $i++) {
            $buyer = $buyers[$i % $buyers->count()];
            $variant = $i % 3 == 0 ? $variant5 : $variant4;
            $qty = $variant->name == '1 Kg' ? 1 : 1;
            
            Order::create([
                'uuid' => Str::uuid(),
                'campaign_id' => $campaign3->id,
                'user_id' => $buyer->id,
                'campaign_variant_id' => $variant->id,
                'cluster_id' => $campaign3->cluster_id,
                'quantity' => $qty,
                'total_quantity' => $variant->package_quantity,
                'total_price' => $qty * $variant->package_quantity * $campaign3->buyer_unit_price,
                'payment_method' => 'cash',
                'payment_status' => 'paid',
                'validation_notes' => 'Pembayaran tunai diterima',
                'idempotency_key' => Str::uuid(),
            ]);
        }

        // Orders for Campaign 4 (Completed - Telur)
        $campaign4 = Campaign::where('title', 'Patungan Telur Ayam Negeri')->first();
        $variant6 = CampaignVariant::where('campaign_id', $campaign4->id)->where('name', '10 Butir')->first();
        $variant7 = CampaignVariant::where('campaign_id', $campaign4->id)->where('name', '30 Butir (1 Tray)')->first();
        
        for ($i = 0; $i < 30; $i++) {
            $buyer = $buyers[$i % $buyers->count()];
            $variant = $i % 4 == 0 ? $variant7 : $variant6;
            $qty = 1;
            
            Order::create([
                'uuid' => Str::uuid(),
                'campaign_id' => $campaign4->id,
                'user_id' => $buyer->id,
                'campaign_variant_id' => $variant->id,
                'cluster_id' => $campaign4->cluster_id,
                'quantity' => $qty,
                'total_quantity' => $variant->package_quantity,
                'total_price' => $qty * $variant->package_quantity * $campaign4->buyer_unit_price,
                'payment_method' => 'cash',
                'payment_status' => 'paid',
                'is_taken' => true,
                'taken_at' => now()->subHours(rand(1, 24)),
                'taken_by_initiator_id' => $initiators[1]->id,
                'validation_notes' => 'Pembayaran diterima',
                'idempotency_key' => Str::uuid(),
            ]);
        }

        // Orders for Campaign 5 (Expired - Tepung)
        $campaign5 = Campaign::where('title', 'Patungan Tepung Terigu')->first();
        $variant8 = CampaignVariant::where('campaign_id', $campaign5->id)->where('name', '1 Kg')->first();
        
        for ($i = 0; $i < 10; $i++) {
            $buyer = $buyers[$i % $buyers->count()];
            
            Order::create([
                'uuid' => Str::uuid(),
                'campaign_id' => $campaign5->id,
                'user_id' => $buyer->id,
                'campaign_variant_id' => $variant8->id,
                'cluster_id' => $campaign5->cluster_id,
                'quantity' => 1,
                'total_quantity' => 1,
                'total_price' => 13000,
                'payment_method' => 'cash',
                'payment_status' => 'paid',
                'validation_notes' => 'Pembayaran diterima sebelum expired',
                'idempotency_key' => Str::uuid(),
            ]);
        }

        $this->command->info('✅ ' . Order::count() . ' orders created successfully!');
        $this->command->table(
            ['Status', 'Count'],
            Order::selectRaw('payment_status, count(*) as count')
                ->groupBy('payment_status')
                ->get()
                ->map(fn($o) => [$o->payment_status, $o->count])
                ->toArray()
        );
    }
}
