<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Supplier;
use App\Models\SupplierProduct;
use App\Models\SupplierOffer;
use App\Models\User;

class SupplierOfferSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $suppliers = Supplier::with('members')->get();

        // Create products for each supplier
        $products = [
            // Supplier 1 - CV Makmur Jaya Abadi
            [
                'supplier_id' => $suppliers[0]->id,
                'name' => 'Beras Premium Pulen',
                'base_unit' => 'kg',
                'description' => 'Beras premium kualitas terbaik, pulen dan wangi',
            ],
            [
                'supplier_id' => $suppliers[0]->id,
                'name' => 'Minyak Goreng',
                'base_unit' => 'liter',
                'description' => 'Minyak goreng berkualitas, cocok untuk masak sehari-hari',
            ],
            // Supplier 2 - PT Sembako Nusantara
            [
                'supplier_id' => $suppliers[1]->id,
                'name' => 'Gula Pasir Putih',
                'base_unit' => 'kg',
                'description' => 'Gula pasir putih berkualitas, manis dan bersih',
            ],
            [
                'supplier_id' => $suppliers[1]->id,
                'name' => 'Telur Ayam Negeri',
                'base_unit' => 'piece',
                'description' => 'Telur ayam segar, ukuran sedang-besar',
            ],
            // Supplier 3 - UD Sumber Rejeki
            [
                'supplier_id' => $suppliers[2]->id,
                'name' => 'Tepung Terigu',
                'base_unit' => 'kg',
                'description' => 'Tepung terigu serbaguna, cocok untuk kue dan roti',
            ],
            [
                'supplier_id' => $suppliers[2]->id,
                'name' => 'Mie Instan',
                'base_unit' => 'pack',
                'description' => 'Mie instan rasa ayam bawang, favorit keluarga',
            ],
        ];

        $productModels = [];
        foreach ($products as $product) {
            $productModels[] = SupplierProduct::create($product);
        }

        // Map supplier index => seller user_id (first member of each supplier)
        $supplierCreators = [];
        foreach ($suppliers as $i => $supplier) {
            $member = $supplier->members->first();
            $supplierCreators[$i] = $member ? $member->user_id : User::first()->id;
        }

        // Create offers for each product
        // Note: title, description, reserved_capacity do NOT exist in supplier_offers schema
        $offers = [
            // Product 1 - Beras Premium Pulen
            [
                'product_index' => 0,
                'supplier_index' => 0,
                'minimum_quantity' => 500,
                'capacity' => 2000,
                'tier_prices' => [
                    ['min' => 500, 'max' => 999, 'price' => 10500],
                    ['min' => 1000, 'max' => 1999, 'price' => 10000],
                    ['min' => 2000, 'max' => null, 'price' => 9500],
                ],
                'service_areas' => ['PGH-RT03', 'PGH-RT05'],
                'delivery_cost' => 200000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            // Product 2 - Minyak Goreng
            [
                'product_index' => 1,
                'supplier_index' => 0,
                'minimum_quantity' => 200,
                'capacity' => 1000,
                'tier_prices' => [
                    ['min' => 200, 'max' => 499, 'price' => 28000],
                    ['min' => 500, 'max' => 999, 'price' => 27000],
                    ['min' => 1000, 'max' => null, 'price' => 26000],
                ],
                'service_areas' => ['PGH-RT03', 'PGH-RT05', 'KBL-RT02'],
                'delivery_cost' => 150000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            // Product 3 - Gula Pasir Putih
            [
                'product_index' => 2,
                'supplier_index' => 1,
                'minimum_quantity' => 300,
                'capacity' => 1500,
                'tier_prices' => [
                    ['min' => 300, 'max' => 599, 'price' => 12500],
                    ['min' => 600, 'max' => 999, 'price' => 12000],
                    ['min' => 1000, 'max' => null, 'price' => 11500],
                ],
                'service_areas' => ['PGH-RT03', 'CPN-RT07'],
                'delivery_cost' => 180000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            // Product 4 - Telur Ayam Negeri
            [
                'product_index' => 3,
                'supplier_index' => 1,
                'minimum_quantity' => 1000,
                'capacity' => 5000,
                'tier_prices' => [
                    ['min' => 1000, 'max' => 1999, 'price' => 2800],
                    ['min' => 2000, 'max' => 3999, 'price' => 2700],
                    ['min' => 4000, 'max' => null, 'price' => 2600],
                ],
                'service_areas' => ['PGH-RT03', 'CPN-RT07', 'PDI-RT11'],
                'delivery_cost' => 250000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            // Product 5 - Tepung Terigu
            [
                'product_index' => 4,
                'supplier_index' => 2,
                'minimum_quantity' => 400,
                'capacity' => 2000,
                'tier_prices' => [
                    ['min' => 400, 'max' => 799, 'price' => 11000],
                    ['min' => 800, 'max' => 1499, 'price' => 10500],
                    ['min' => 1500, 'max' => null, 'price' => 10000],
                ],
                'service_areas' => ['CDA-RT04', 'TBH-RT09'],
                'delivery_cost' => 160000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
            // Product 6 - Mie Instan
            [
                'product_index' => 5,
                'supplier_index' => 2,
                'minimum_quantity' => 100,
                'capacity' => 500,
                'tier_prices' => [
                    ['min' => 100, 'max' => 199, 'price' => 95000],
                    ['min' => 200, 'max' => 399, 'price' => 92000],
                    ['min' => 400, 'max' => null, 'price' => 90000],
                ],
                'service_areas' => ['CDA-RT04', 'TBH-RT09', 'STB-RT12'],
                'delivery_cost' => 200000,
                'valid_until' => now()->addDays(30),
                'status' => 'active',
            ],
        ];

        foreach ($offers as $offer) {
            $product = $productModels[$offer['product_index']];
            $createdById = $supplierCreators[$offer['supplier_index']];

            $product->offers()->create([
                'supplier_id'      => $product->supplier_id,
                'created_by_id'    => $createdById,
                'minimum_quantity' => $offer['minimum_quantity'],
                'capacity'         => $offer['capacity'],
                'tier_prices'      => $offer['tier_prices'],
                'service_areas'    => $offer['service_areas'],
                'delivery_cost'    => $offer['delivery_cost'],
                'valid_until'      => $offer['valid_until'],
                'status'           => $offer['status'],
            ]);
        }

        $this->command->info('✅ ' . SupplierOffer::count() . ' supplier offers created successfully!');
        $this->command->table(
            ['Supplier', 'Products', 'Offers'],
            Supplier::with(['products.offers'])->get()->map(fn($s) => [
                $s->name,
                $s->products->count(),
                $s->products->sum(fn($p) => $p->offers->count()),
            ])->toArray()
        );
    }
}
