<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->command->info('🌱 Starting database seeding...');
        
        $this->call([
            RolePermissionSeeder::class,
            ClusterSeeder::class,
            UserSeeder::class,
            SupplierSeeder::class,
            SupplierOfferSeeder::class,
            CampaignSeeder::class,
            OrderSeeder::class,
            NotificationSeeder::class,
            TransactionLogSeeder::class,
        ]);

        $this->command->info('✅ Database seeding completed successfully!');
    }
}
