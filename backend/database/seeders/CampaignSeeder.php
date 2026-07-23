<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Campaign;
use App\Models\CampaignVariant;
use App\Models\User;
use App\Models\Cluster;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class CampaignSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $initiators = User::role('initiator')->get();
        
        // Campaign 1 - Active (PGH-RT03)
        $campaign1 = Campaign::create([
            'uuid' => Str::uuid(),
            'title' => 'Patungan Beras Premium Pulen',
            'description' => 'Beras premium kualitas terbaik, pulen dan wangi. Langsung dari supplier terpercaya.',
            'status' => 'active',
            'initiator_id' => $initiators[0]->id,
            'cluster_id' => $initiators[0]->cluster_id,
            'supplier_id' => 1,
            'offer_id' => 1,
            'offer_snapshot' => json_encode([
                'supplier_name' => 'CV Makmur Jaya Abadi',
                'product_name' => 'Beras Premium Pulen 5Kg',
                'base_unit' => 'kg',
                'supplier_unit_price' => 10000,
                'delivery_cost' => 200000,
            ]),
            'supplier_unit_price' => 10000,
            'buyer_unit_price' => 12000,
            'unit' => 'kg',
            'target_quantity' => 1000,
            'current_quantity' => 650,
            'max_quantity' => 2000,
            'deadline' => now()->addDays(2),
            'location_distribution' => 'Rumah Pak RT - Jl. Mawar No. 12, RT03',
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign1->id,
            'name' => '5 Kg',
            'package_quantity' => 5,
            'max_quantity' => 100,
            'sold_quantity' => 80,
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign1->id,
            'name' => '10 Kg',
            'package_quantity' => 10,
            'max_quantity' => 50,
            'sold_quantity' => 35,
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign1->id,
            'name' => '25 Kg (Sak)',
            'package_quantity' => 25,
            'max_quantity' => 20,
            'sold_quantity' => 8,
        ]);

        // Campaign 2 - Active (PGH-RT03)
        $campaign2 = Campaign::create([
            'uuid' => Str::uuid(),
            'title' => 'Patungan Minyak Goreng 2L',
            'description' => 'Minyak goreng berkualitas, cocok untuk masak sehari-hari. Harga lebih hemat!',
            'status' => 'active',
            'initiator_id' => $initiators[0]->id,
            'cluster_id' => $initiators[0]->cluster_id,
            'supplier_id' => 1,
            'offer_id' => 2,
            'offer_snapshot' => json_encode([
                'supplier_name' => 'CV Makmur Jaya Abadi',
                'product_name' => 'Minyak Goreng 2L',
                'base_unit' => 'liter',
                'supplier_unit_price' => 27000,
                'delivery_cost' => 150000,
            ]),
            'supplier_unit_price' => 27000,
            'buyer_unit_price' => 32000,
            'unit' => 'liter',
            'target_quantity' => 500,
            'current_quantity' => 320,
            'max_quantity' => 1000,
            'deadline' => now()->addDays(3),
            'location_distribution' => 'Rumah Pak RT - Jl. Mawar No. 12, RT03',
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign2->id,
            'name' => '2 Liter',
            'package_quantity' => 2,
            'max_quantity' => 150,
            'sold_quantity' => 120,
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign2->id,
            'name' => '5 Liter',
            'package_quantity' => 5,
            'max_quantity' => 40,
            'sold_quantity' => 20,
        ]);

        // Campaign 3 - Target Reached (PGH-RT05)
        $campaign3 = Campaign::create([
            'uuid' => Str::uuid(),
            'title' => 'Patungan Gula Pasir Putih',
            'description' => 'Gula pasir putih berkualitas, manis dan bersih. Cocok untuk keperluan harian.',
            'status' => 'target_reached',
            'initiator_id' => $initiators[1]->id,
            'cluster_id' => $initiators[1]->cluster_id,
            'supplier_id' => 2,
            'offer_id' => 3,
            'offer_snapshot' => json_encode([
                'supplier_name' => 'PT Sembako Nusantara',
                'product_name' => 'Gula Pasir Putih 1Kg',
                'base_unit' => 'kg',
                'supplier_unit_price' => 12000,
                'delivery_cost' => 180000,
            ]),
            'supplier_unit_price' => 12000,
            'buyer_unit_price' => 14500,
            'unit' => 'kg',
            'target_quantity' => 600,
            'current_quantity' => 600,
            'max_quantity' => 1500,
            'deadline' => now()->addDays(5),
            'completed_at' => now(),
            'location_distribution' => 'Rumah Bu Ratna - Jl. Melati No. 8, RT05',
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign3->id,
            'name' => '1 Kg',
            'package_quantity' => 1,
            'max_quantity' => 300,
            'sold_quantity' => 300,
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign3->id,
            'name' => '5 Kg',
            'package_quantity' => 5,
            'max_quantity' => 60,
            'sold_quantity' => 60,
        ]);

        // Campaign 4 - Completed (PGH-RT05)
        $campaign4 = Campaign::create([
            'uuid' => Str::uuid(),
            'title' => 'Patungan Telur Ayam Negeri',
            'description' => 'Telur ayam segar, ukuran sedang-besar. Langsung dari peternak.',
            'status' => 'completed',
            'initiator_id' => $initiators[1]->id,
            'cluster_id' => $initiators[1]->cluster_id,
            'supplier_id' => 2,
            'offer_id' => 4,
            'offer_snapshot' => json_encode([
                'supplier_name' => 'PT Sembako Nusantara',
                'product_name' => 'Telur Ayam Negeri',
                'base_unit' => 'piece',
                'supplier_unit_price' => 2700,
                'delivery_cost' => 250000,
            ]),
            'supplier_unit_price' => 2700,
            'buyer_unit_price' => 3200,
            'unit' => 'piece',
            'target_quantity' => 2000,
            'current_quantity' => 2000,
            'max_quantity' => 5000,
            'deadline' => now()->subDays(2),
            'completed_at' => now()->subDays(1),
            'distribution_completed_at' => now(),
            'location_distribution' => 'Rumah Bu Ratna - Jl. Melati No. 8, RT05',
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign4->id,
            'name' => '10 Butir',
            'package_quantity' => 10,
            'max_quantity' => 100,
            'sold_quantity' => 100,
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign4->id,
            'name' => '30 Butir (1 Tray)',
            'package_quantity' => 30,
            'max_quantity' => 33,
            'sold_quantity' => 33,
        ]);

        // Campaign 5 - Expired (KBL-RT02)
        $campaign5 = Campaign::create([
            'uuid' => Str::uuid(),
            'title' => 'Patungan Tepung Terigu',
            'description' => 'Tepung terigu serbaguna, cocok untuk kue dan roti.',
            'status' => 'expired',
            'initiator_id' => $initiators[2]->id,
            'cluster_id' => $initiators[2]->cluster_id,
            'supplier_id' => 3,
            'offer_id' => 5,
            'offer_snapshot' => json_encode([
                'supplier_name' => 'UD Sumber Rejeki',
                'product_name' => 'Tepung Terigu 1Kg',
                'base_unit' => 'kg',
                'supplier_unit_price' => 10500,
                'delivery_cost' => 160000,
            ]),
            'supplier_unit_price' => 10500,
            'buyer_unit_price' => 13000,
            'unit' => 'kg',
            'target_quantity' => 800,
            'current_quantity' => 320,
            'max_quantity' => 2000,
            'deadline' => now()->subDays(1),
            'completed_at' => now()->subDays(1),
            'location_distribution' => 'Rumah Pak Budi - Jl. Anggrek No. 5, RT02',
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign5->id,
            'name' => '1 Kg',
            'package_quantity' => 1,
            'max_quantity' => 400,
            'sold_quantity' => 160,
        ]);

        CampaignVariant::create([
            'campaign_id' => $campaign5->id,
            'name' => '5 Kg',
            'package_quantity' => 5,
            'max_quantity' => 80,
            'sold_quantity' => 32,
        ]);

        $this->command->info('✅ ' . Campaign::count() . ' campaigns created successfully!');
        $this->command->table(
            ['Status', 'Count'],
            Campaign::selectRaw('status, count(*) as count')
                ->groupBy('status')
                ->get()
                ->map(fn($c) => [$c->status, $c->count])
                ->toArray()
        );
    }
}
