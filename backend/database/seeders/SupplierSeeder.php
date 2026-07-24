<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Supplier;
use Spatie\Permission\Models\Role;

class SupplierSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $sellerRole = Role::findByName('seller', 'web');

        // Create suppliers using Eloquent
        $suppliers = [
            [
                'name' => 'CV Makmur Jaya Abadi',
                'description' => 'Distributor sembako terpercaya sejak 1995',
                'address' => 'Jl. Industri Raya No. 45, Jakarta Timur',
                'contact_business' => '021-87654321',
                'verification_status' => 'approved',
                'service_areas' => ['PGH-RT03', 'PGH-RT05', 'KBL-RT02'],
            ],
            [
                'name' => 'PT Sembako Nusantara',
                'description' => 'Supplier beras dan minyak goreng berkualitas',
                'address' => 'Jl. Gudang Selatan No. 12, Jakarta Utara',
                'contact_business' => '021-55566677',
                'verification_status' => 'approved',
                'service_areas' => ['PGH-RT03', 'CPN-RT07', 'PDI-RT11'],
            ],
            [
                'name' => 'UD Sumber Rejeki',
                'description' => 'Pemasok gula dan tepung terigu',
                'address' => 'Jl. Pasar Baru No. 78, Jakarta Barat',
                'contact_business' => '021-12345678',
                'verification_status' => 'approved',
                'service_areas' => ['CDA-RT04', 'TBH-RT09', 'STB-RT12'],
            ],
        ];

        $supplierModels = [];
        foreach ($suppliers as $supplier) {
            $supplierModels[] = Supplier::create($supplier);
        }

        // Create seller users and assign to suppliers using relationships
        $sellers = [
            [
                'name' => 'Pak Hendra Gunawan',
                'phone_number' => '081112233445',
                'supplier_index' => 0,
                'member_role' => 'owner',
            ],
            [
                'name' => 'Bu Sari Wulandari',
                'phone_number' => '081223344556',
                'supplier_index' => 0,
                'member_role' => 'sales',
            ],
            [
                'name' => 'Pak Andi Firmansyah',
                'phone_number' => '081334455667',
                'supplier_index' => 1,
                'member_role' => 'owner',
            ],
            [
                'name' => 'Pak Rudi Hartono',
                'phone_number' => '081445566778',
                'supplier_index' => 1,
                'member_role' => 'warehouse',
            ],
            [
                'name' => 'Bu Dewi Kartika',
                'phone_number' => '081556677889',
                'supplier_index' => 2,
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
            $user->assignRole($sellerRole);

            // Create supplier member using relationship
            $supplierModels[$seller['supplier_index']]->members()->create([
                'user_id' => $user->id,
                'member_role' => $seller['member_role'],
            ]);
        }

        $this->command->info('✅ Suppliers and sellers created successfully!');
        $this->command->table(
            ['Supplier', 'Members'],
            Supplier::with('members')->get()->map(fn($s) => [$s->name, $s->members->count()])->toArray()
        );
    }
}
