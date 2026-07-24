<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\Campaign;
use App\Models\TransactionLog;

class TransactionLogSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $orders = Order::with(['campaign'])->get();

        foreach ($orders as $order) {
            // Create order creation log using morphMany relationship
            // Schema: type, initiator_id, before_data, after_data, ip_address, user_agent
            $order->logs()->create([
                'type'         => 'order_created',
                'initiator_id' => $order->user_id,
                'before_data'  => null,
                'after_data'   => [
                    'order_id'    => $order->uuid,
                    'campaign_id' => $order->campaign_id,
                    'quantity'    => $order->quantity,
                    'total_price' => $order->total_price,
                ],
                'ip_address' => '127.0.0.1',
                'user_agent' => 'Grosirun Seeder',
            ]);

            // If order has proof
            if ($order->proof_path) {
                $order->logs()->create([
                    'type'         => 'proof_uploaded',
                    'initiator_id' => $order->user_id,
                    'before_data'  => null,
                    'after_data'   => [
                        'proof_path' => $order->proof_path,
                    ],
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                ]);
            }

            // If order is paid
            if ($order->payment_status === 'paid') {
                $order->logs()->create([
                    'type'         => 'payment_validated',
                    'initiator_id' => $order->campaign->initiator_id,
                    'before_data'  => [
                        'payment_status' => $order->payment_method === 'cash' ? 'pending' : 'waiting_qris',
                    ],
                    'after_data'   => [
                        'payment_status' => 'paid',
                    ],
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                ]);
            }

            // If order is taken
            if ($order->is_taken) {
                $order->logs()->create([
                    'type'         => 'order_taken',
                    'initiator_id' => $order->taken_by_initiator_id,
                    'before_data'  => [
                        'is_taken' => false,
                    ],
                    'after_data'   => [
                        'is_taken' => true,
                        'taken_at' => $order->taken_at,
                    ],
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                ]);
            }
        }

        $this->command->info('✅ ' . TransactionLog::count() . ' transaction logs created successfully!');
        $this->command->table(
            ['Type', 'Count'],
            TransactionLog::selectRaw('`type`, count(*) as count')
                ->groupBy('type')
                ->get()
                ->map(fn($log) => [$log->type, $log->count])
                ->toArray()
        );
    }
}
