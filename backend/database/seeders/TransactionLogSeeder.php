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
            // Create order creation log using relationship
            $order->logs()->create([
                'action' => 'order_created',
                'user_id' => $order->user_id,
                'before' => null,
                'after' => [
                    'order_id' => $order->uuid,
                    'campaign_id' => $order->campaign_id,
                    'quantity' => $order->quantity,
                    'total_price' => $order->total_price,
                ],
                'ip_address' => '127.0.0.1',
                'user_agent' => 'Grosirun Seeder',
            ]);

            // If order has proof
            if ($order->proof_path) {
                $order->logs()->create([
                    'action' => 'proof_uploaded',
                    'user_id' => $order->user_id,
                    'before' => null,
                    'after' => [
                        'proof_path' => $order->proof_path,
                    ],
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                ]);
            }

            // If order is paid
            if ($order->payment_status === 'paid') {
                $order->logs()->create([
                    'action' => 'payment_validated',
                    'user_id' => $order->campaign->initiator_id,
                    'before' => [
                        'payment_status' => $order->payment_method === 'cash' ? 'pending' : 'waiting_qris',
                    ],
                    'after' => [
                        'payment_status' => 'paid',
                    ],
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                ]);
            }

            // If order is taken
            if ($order->is_taken) {
                $order->logs()->create([
                    'action' => 'order_taken',
                    'user_id' => $order->taken_by_initiator_id,
                    'before' => [
                        'is_taken' => false,
                    ],
                    'after' => [
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
            ['Action', 'Count'],
            TransactionLog::selectRaw('action, count(*) as count')
                ->groupBy('action')
                ->get()
                ->map(fn($log) => [$log->action, $log->count])
                ->toArray()
        );
    }
}
