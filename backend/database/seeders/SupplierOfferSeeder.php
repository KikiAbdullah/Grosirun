<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class SupplierOfferSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $offers = [
            // Supplier 1 - CV Makmur Jaya Abadi
            [
                'uuid' => Str::uuid(),
                'supplier_id' => 1,
                'title' => 'Beras Premium Pulen 5Kg',
                'description' => 'Beras premium kualitas terbaik, pulen dan wangi',
                'base_unit' => 'kg',
                'minimum_quantity' => 500,
                'capacity' => 2000,
                'reserved_capacity' => 0,
                'tier_prices' => json_encode([
                    ['min' => 500, 'max' => 999, 'price' => 10500],
                    ['min' => 1000, 'max' => 1999, 'price' => 10000],
                    ['min' => 2000, 'max' => null, 'price' => 9500],
                ]),
                'service_areas' => json_encode(['PGH-RT03', 'PGH-RT05']),
                'delivery_cost' => 200000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            [
                'uuid' => Str::uuid(),
                'supplier_id' => 1,
                'title' => 'Minyak Goreng 2L',
                'description' => 'Minyak goreng berkualitas, cocok untuk masak sehari-hari',
                'base_unit' => 'liter',
                'minimum_quantity' => 200,
                'capacity' => 1000,
                'reserved_capacity' => 0,
                'tier_prices' => json_encode([
                    ['min' => 200, 'max' => 499, 'price' => 28000],
                    ['min' => 500, 'max' => 999, 'price' => 27000],
                    ['min' => 1000, 'max' => null, 'price' => 26000],
                ]),
                'service_areas' => json_encode(['PGH-RT03', 'PGH-RT05', 'KBL-RT02']),
                'delivery_cost' => 150000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],

            // Supplier 2 - PT Sembako Nusantara
            [
                'uuid' => Str::uuid(),
                'supplier_id' => 2,
                'title' => 'Gula Pasir Putih 1Kg',
                'description' => 'Gula pasir putih berkualitas, manis dan bersih',
                'base_unit' => 'kg',
                'minimum_quantity' => 300,
                'capacity' => 1500,
                'reserved_capacity' => 0,
                'tier_prices' => json_encode([
                    ['min' => 300, 'max' => 599, 'price' => 12500],
                    ['min' => 600, 'max' => 999, 'price' => 12000],
                    ['min' => 1000, 'max' => null, 'price' => 11500],
                ]),
                'service_areas' => json_encode(['PGH-RT03', 'CPN-RT07']),
                'delivery_cost' => 180000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            [
                'uuid' => Str::uuid(),
                'supplier_id' => 2,
                'title' => 'Telur Ayam Negeri',
                'description' => 'Telur ayam segar, ukuran sedang-besar',
                'base_unit' => 'piece',
                'minimum_quantity' => 1000,
                'capacity' => 5000,
                'reserved_capacity' => 0,
                'tier_prices' => json_encode([
                    ['min' => 1000, 'max' => 1999, 'price' => 2800],
                    ['min' => 2000, 'max' => 3999, 'price' => 2700],
                    ['min' => 4000, 'max' => null, 'price' => 2600],
                ]),
                'service_areas' => json_encode(['PGH-RT03', 'CPN-RT07', 'PDI-RT11']),
                'delivery_cost' => 250000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],

            // Supplier 3 - UD Sumber Rejeki
            [
                'uuid' => Str::uuid(),
                'supplier_id' => 3,
                'title' => 'Tepung Terigu 1Kg',
                'description' => 'Tepung terigu serbaguna, cocok untuk kue dan roti',
                'base_unit' => 'kg',
                'minimum_quantity' => 400,
                'capacity' => 2000,
                'reserved_capacity' => 0,
                'tier_prices' => json_encode([
                    ['min' => 400, 'max' => 799, 'price' => 11000],
                    ['min' => 800, 'max' => 1499, 'price' => 10500],
                    ['min' => 1500, 'max' => null, 'price' => 10000],
                ]),
                'service_areas' => json_encode(['CDA-RT04', 'TBH-RT09']),
                'delivery_cost' => 160000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            [
                'uuid' => Str::uuid(),
                'supplier_id' => 3,
                'title' => 'Mie Instan 1 Dus (40 pcs)',
                'description' => 'Mie instan rasa ayam bawang, favorit keluarga',
                'base_unit' => 'pack',
                'minimum_quantity' => 100,
                'capacity' => 500,
                'reserved_capacity' => 0,
                'tier_prices' => json_encode([
                    ['min' => 100, 'max' => 199, 'price' => 95000],
                    ['min' => 200, 'max' => 399, 'price' => 92000],
                    ['min' => 400, 'max' => null, 'price' => 90000],
                ]),
                'service_areas' => json_encode(['CDA-RT04', 'TBH-RT09', 'STB-RT12']),
                'delivery_cost' => 200000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
        ];

        foreach ($offers as $offer) {
            DB::table('supplier_offers')->insert(array_merge($offer, [
                'created_at' => now(),
                'updated_at' => now(),
            ]));
        }

        $this->command->info('✅ ' . DB::table('supplier_offers')->count() . ' supplier offers created successfully!');
    }
}
