<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Notification;
use App\Models\User;

class NotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = User::all();
        
        $notifications = [
            [
                'title' => '🎉 Patungan Beras Hampir Penuh!',
                'body' => 'Patungan Beras Premium Pulen sudah mencapai 65%. Yuk ikut patungan sebelum kehabisan!',
                'data' => json_encode(['type' => 'campaign_progress', 'campaign_id' => 1]),
            ],
            [
                'title' => '✅ Pembayaran Diterima',
                'body' => 'Pembayaran Anda untuk Patungan Beras Premium Pulen (5 Kg) telah diterima.',
                'data' => json_encode(['type' => 'payment_validated', 'order_id' => 1]),
            ],
            [
                'title' => '📦 Barang Siap Diambil',
                'body' => 'Patungan Telur Ayam Negeri sudah selesai distribusi. Silakan ambil di lokasi yang ditentukan.',
                'data' => json_encode(['type' => 'distribution_ready', 'campaign_id' => 4]),
            ],
            [
                'title' => '⏰ Deadline Patungan',
                'body' => 'Patungan Minyak Goreng 2L akan berakhir dalam 3 hari. Yuk segera ikut patungan!',
                'data' => json_encode(['type' => 'campaign_deadline', 'campaign_id' => 2]),
            ],
            [
                'title' => '💰 Tagihan Platform Fee',
                'body' => 'Tagihan platform fee untuk Patungan Gula Pasir Putih sebesar Rp72.500 telah diterbitkan.',
                'data' => json_encode(['type' => 'platform_fee_invoice', 'campaign_id' => 3]),
            ],
            [
                'title' => '🔄 Pembatalan Patungan',
                'body' => 'Patungan Tepung Terigu dibatalkan karena target tidak tercapai. Refund akan diproses.',
                'data' => json_encode(['type' => 'campaign_cancelled', 'campaign_id' => 5]),
            ],
            [
                'title' => '📋 Bukti Pembayaran Ditolak',
                'body' => 'Bukti pembayaran Anda ditolak karena foto blur. Silakan upload ulang dengan foto yang lebih jelas.',
                'data' => json_encode(['type' => 'proof_rejected', 'order_id' => 5]),
            ],
            [
                'title' => '🎊 Target Tercapai!',
                'body' => 'Patungan Gula Pasir Putih telah mencapai target 600 Kg. PO akan segera dibuat.',
                'data' => json_encode(['type' => 'target_reached', 'campaign_id' => 3]),
            ],
            [
                'title' => '📊 Rekap Patungan Tersedia',
                'body' => 'Rekap PDF untuk Patungan Telur Ayam Negeri sudah tersedia. Silakan download.',
                'data' => json_encode(['type' => 'recap_available', 'campaign_id' => 4]),
            ],
            [
                'title' => '🔔 Pengingat Pembayaran',
                'body' => 'Anda memiliki pesanan yang belum dibayar. Silakan bayar ke Initiator untuk melanjutkan.',
                'data' => json_encode(['type' => 'payment_reminder', 'order_id' => 10]),
            ],
        ];

        foreach ($users as $user) {
            // Give each user 3-5 random notifications
            $userNotifications = $notifications;
            shuffle($userNotifications);
            $count = rand(3, 5);
            
            for ($i = 0; $i < $count; $i++) {
                $notif = $userNotifications[$i];
                Notification::create([
                    'user_id' => $user->id,
                    'title' => $notif['title'],
                    'body' => $notif['body'],
                    'data' => $notif['data'],
                    'read_at' => rand(0, 1) ? now()->subHours(rand(1, 48)) : null,
                ]);
            }
        }

        $this->command->info('✅ ' . Notification::count() . ' notifications created successfully!');
        $this->command->table(
            ['Status', 'Count'],
            [
                ['Read', Notification::whereNotNull('read_at')->count()],
                ['Unread', Notification::whereNull('read_at')->count()],
            ]
        );
    }
}
