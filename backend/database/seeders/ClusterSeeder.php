<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Cluster;

class ClusterSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $clusters = [
            [
                'name' => 'Permata Hijau RT03',
                'code' => 'PGH-RT03',
                'rw' => 'RW01',
                'kelurahan' => 'Permata Hijau',
                'kota' => 'Jakarta Selatan',
            ],
            [
                'name' => 'Permata Hijau RT05',
                'code' => 'PGH-RT05',
                'rw' => 'RW01',
                'kelurahan' => 'Permata Hijau',
                'kota' => 'Jakarta Selatan',
            ],
            [
                'name' => 'Kebayoran Lama RT02',
                'code' => 'KBL-RT02',
                'rw' => 'RW03',
                'kelurahan' => 'Kebayoran Lama Selatan',
                'kota' => 'Jakarta Selatan',
            ],
            [
                'name' => 'Cipinang RT07',
                'code' => 'CPN-RT07',
                'rw' => 'RW05',
                'kelurahan' => 'Cipinang Besar Selatan',
                'kota' => 'Jakarta Timur',
            ],
            [
                'name' => 'Pondok Indah RT11',
                'code' => 'PDI-RT11',
                'rw' => 'RW08',
                'kelurahan' => 'Pondok Pinang',
                'kota' => 'Jakarta Selatan',
            ],
            [
                'name' => 'Cilandak RT04',
                'code' => 'CDA-RT04',
                'rw' => 'RW02',
                'kelurahan' => 'Cilandak Barat',
                'kota' => 'Jakarta Selatan',
            ],
            [
                'name' => 'Tebet RT09',
                'code' => 'TBH-RT09',
                'rw' => 'RW06',
                'kelurahan' => 'Tebet Barat',
                'kota' => 'Jakarta Selatan',
            ],
            [
                'name' => 'Setiabudi RT12',
                'code' => 'STB-RT12',
                'rw' => 'RW04',
                'kelurahan' => 'Setiabudi',
                'kota' => 'Jakarta Selatan',
            ],
        ];

        foreach ($clusters as $cluster) {
            Cluster::create($cluster);
        }

        $this->command->info('✅ ' . Cluster::count() . ' clusters created successfully!');
    }
}
