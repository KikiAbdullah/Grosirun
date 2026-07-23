<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class SupplierSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create suppliers
        $suppliers = [
            [
                'name' => 'CV Makmur Jaya Abadi',
                'description' => 'Distributor sembako terpercaya sejak 1995',
                'address' => 'Jl. Industri Raya No. 45, Jakarta Timur',
                'contact_business' => '021-87654321',
                'verification_status' => 'approved',
                'service_areas' => json_encode(['PGH-RT03', 'PGH-RT05', 'KBL-RT02']),
            ],
            [
                'name' => 'PT Sembako Nusantara',
                'description' => 'Supplier beras dan minyak goreng berkualitas',
                'address' => 'Jl. Gudang Selatan No. 12, Jakarta Utara',
                'contact_business' => '021-55566677',
                'verification_status' => 'approved',
                'service_areas' => json_encode(['PGH-RT03', 'CPN-RT07', 'PDI-RT11']),
            ],
            [
                'name' => 'UD Sumber Rejeki',
                'description' => 'Pemasok gula dan tepung terigu',
                'address' => 'Jl. Pasar Baru No. 78, Jakarta Barat',
                'contact_business' => '021-12345678',
                'verification_status' => 'approved',
                'service_areas' => json_encode(['CDA-RT04', 'TBH-RT09', 'STB-RT12']),
            ],
        ];

        foreach ($suppliers as $supplier) {
            DB::table('suppliers')->insert(array_merge($supplier, [
                'created_at' => now(),
                'updated_at' => now(),
            ]));
        }

        // Create seller users and assign to suppliers
        $sellers = [
            [
                'name' => 'Pak Hendra Gunawan',
                'phone_number' => '081112233445',
                'supplier_id' => 1,
                'member_role' => 'owner',
            ],
            [
                'name' => 'Bu Sari Wulandari',
                'phone_number' => '081223344556',
                'supplier_id' => 1,
                'member_role' => 'sales',
            ],
            [
                'name' => 'Pak Andi Firmansyah',
                'phone_number' => '081334455667',
                'supplier_id' => 2,
                'member_role' => 'owner',
            ],
            [
                'name' => 'Pak Rudi Hartono',
                'phone_number' => '081445566778',
                'supplier_id' => 2,
                'member_role' => 'warehouse',
            ],
            [
                'name' => 'Bu Dewi Kartika',
                'phone_number' => '081556677889',
                'supplier_id' => 3,
                'member_role' => 'owner',
            ],
        ];

        foreach ($sellers as $seller) {
            $user = User::firstOrCreate(
                ['phone_number' => $seller['phone_number']],
                [
                    'name' => $seller['name'],
                    'role' => 'seller',
                    'active_role' => 'seller',
                    'consent_at' => now(),
                    'consent_version' => '1.0',
                    'tos_accepted_at' => now(),
                    'tos_version' => '1.0',
                ]
            );

            // Assign seller role
            $user->assignRole('seller');

            // Create supplier member
            DB::table('supplier_members')->insert([
                'supplier_id' => $seller['supplier_id'],
                'user_id' => $user->id,
                'member_role' => $seller['member_role'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('✅ Suppliers and sellers created successfully!');
        $this->command->table(
            ['Supplier', 'Members'],
            DB::table('suppliers')
                ->join('supplier_members', 'suppliers.id', '=', 'supplier_members.supplier_id')
                ->groupBy('suppliers.id', 'suppliers.name')
                ->select('suppliers.name', DB::raw('count(supplier_members.id) as members'))
                ->get()
                ->map(fn($s) => [$s->name, $s->members])
                ->toArray()
        );
    }
}
