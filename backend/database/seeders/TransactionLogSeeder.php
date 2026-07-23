<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\Campaign;
use Illuminate\Support\Facades\DB;

class TransactionLogSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $orders = Order::all();
        
        foreach ($orders as $order) {
            // Create order creation log
            DB::table('transaction_logs')->insert([
                'type' => 'order_created',
                'loggable_type' => Order::class,
                'loggable_id' => $order->id,
                'user_id' => $order->user_id,
                'before_data' => null,
                'after_data' => json_encode([
                    'order_id' => $order->uuid,
                    'campaign_id' => $order->campaign_id,
                    'quantity' => $order->quantity,
                    'total_price' => $order->total_price,
                ]),
                'notes' => 'Pesanan dibuat',
                'ip_address' => '127.0.0.1',
                'user_agent' => 'Grosirun Seeder',
                'created_at' => $order->created_at,
                'updated_at' => $order->created_at,
            ]);

            // If order has proof
            if ($order->proof_path) {
                DB::table('transaction_logs')->insert([
                    'type' => 'proof_uploaded',
                    'loggable_type' => Order::class,
                    'loggable_id' => $order->id,
                    'user_id' => $order->user_id,
                    'before_data' => null,
                    'after_data' => json_encode([
                        'proof_path' => $order->proof_path,
                    ]),
                    'notes' => 'Bukti pembayaran diupload',
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                    'created_at' => $order->created_at->addMinutes(5),
                    'updated_at' => $order->created_at->addMinutes(5),
                ]);
            }

            // If order is paid
            if ($order->payment_status === 'paid') {
                DB::table('transaction_logs')->insert([
                    'type' => 'payment_validated',
                    'loggable_type' => Order::class,
                    'loggable_id' => $order->id,
                    'user_id' => Campaign::find($order->campaign_id)->initiator_id,
                    'before_data' => json_encode([
                        'payment_status' => $order->payment_method === 'cash' ? 'pending' : 'waiting_qris',
                    ]),
                    'after_data' => json_encode([
                        'payment_status' => 'paid',
                    ]),
                    'notes' => $order->validation_notes ?? 'Pembayaran divalidasi',
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                    'created_at' => $order->created_at->addMinutes(30),
                    'updated_at' => $order->created_at->addMinutes(30),
                ]);
            }

            // If order is taken
            if ($order->is_taken) {
                DB::table('transaction_logs')->insert([
                    'type' => 'order_taken',
                    'loggable_type' => Order::class,
                    'loggable_id' => $order->id,
                    'user_id' => $order->taken_by_initiator_id,
                    'before_data' => json_encode([
                        'is_taken' => false,
                    ]),
                    'after_data' => json_encode([
                        'is_taken' => true,
                        'taken_at' => $order->taken_at,
                    ]),
                    'notes' => 'Barang diambil oleh pembeli',
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'Grosirun Seeder',
                    'created_at' => $order->taken_at,
                    'updated_at' => $order->taken_at,
                ]);
            }
        }

        $this->command->info('✅ ' . DB::table('transaction_logs')->count() . ' transaction logs created successfully!');
    }
}
