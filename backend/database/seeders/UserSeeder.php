<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Cluster;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $clusters = Cluster::all();

        // Super Admin (already created in RolePermissionSeeder)
        $admin = User::where('phone_number', '081234567890')->first();
        if (!$admin) {
            $admin = User::create([
                'name' => 'Admin Grosirun',
                'phone_number' => '081234567890',
                'role' => 'admin',
                'active_role' => 'admin',
                'cluster_id' => null,
                'consent_at' => now(),
                'consent_version' => '1.0',
                'tos_accepted_at' => now(),
                'tos_version' => '1.0',
            ]);
        }
        $admin->assignRole('super_admin');

        // Initiators (Ketua RT)
        $initiators = [
            [
                'name' => 'Pak Agus Setiawan',
                'phone_number' => '081111111111',
                'cluster_id' => $clusters[0]->id, // PGH-RT03
                'role' => 'initiator',
                'active_role' => 'initiator',
            ],
            [
                'name' => 'Bu Ratna Dewi',
                'phone_number' => '081222222222',
                'cluster_id' => $clusters[1]->id, // PGH-RT05
                'role' => 'initiator',
                'active_role' => 'initiator',
            ],
            [
                'name' => 'Pak Budi Santoso',
                'phone_number' => '081333333333',
                'cluster_id' => $clusters[2]->id, // KBL-RT02
                'role' => 'initiator',
                'active_role' => 'initiator',
            ],
        ];

        foreach ($initiators as $data) {
            $user = User::firstOrCreate(
                ['phone_number' => $data['phone_number']],
                array_merge($data, [
                    'consent_at' => now(),
                    'consent_version' => '1.0',
                    'tos_accepted_at' => now(),
                    'tos_version' => '1.0',
                ])
            );
            $user->assignRole('initiator');
        }

        // Buyers (Warga RT)
        $buyers = [
            ['name' => 'Bu Siti Rahayu', 'phone_number' => '081444444444', 'cluster_id' => $clusters[0]->id],
            ['name' => 'Pak Joko Widodo', 'phone_number' => '081555555555', 'cluster_id' => $clusters[0]->id],
            ['name' => 'Bu Nengsih Putri', 'phone_number' => '081666666666', 'cluster_id' => $clusters[0]->id],
            ['name' => 'Pak Herman Wijaya', 'phone_number' => '081777777777', 'cluster_id' => $clusters[0]->id],
            ['name' => 'Bu Ani Suryani', 'phone_number' => '081888888888', 'cluster_id' => $clusters[0]->id],
            ['name' => 'Pak Dedi Kurniawan', 'phone_number' => '081999999999', 'cluster_id' => $clusters[1]->id],
            ['name' => 'Bu Lina Marlina', 'phone_number' => '081000000001', 'cluster_id' => $clusters[1]->id],
            ['name' => 'Pak Rudi Hartono', 'phone_number' => '081000000002', 'cluster_id' => $clusters[2]->id],
            ['name' => 'Bu Maya Sari', 'phone_number' => '081000000003', 'cluster_id' => $clusters[2]->id],
            ['name' => 'Pak Agus Prasetyo', 'phone_number' => '081000000004', 'cluster_id' => $clusters[3]->id],
        ];

        foreach ($buyers as $data) {
            $user = User::firstOrCreate(
                ['phone_number' => $data['phone_number']],
                array_merge($data, [
                    'role' => 'buyer',
                    'active_role' => 'buyer',
                    'consent_at' => now(),
                    'consent_version' => '1.0',
                    'tos_accepted_at' => now(),
                    'tos_version' => '1.0',
                ])
            );
            $user->assignRole('buyer');
        }

        $this->command->info('✅ ' . User::count() . ' users created successfully!');
        $this->command->table(
            ['Role', 'Count'],
            [
                ['Super Admin', User::role('super_admin')->count()],
                ['Initiator', User::role('initiator')->count()],
                ['Buyer', User::role('buyer')->count()],
            ]
        );
    }
}
