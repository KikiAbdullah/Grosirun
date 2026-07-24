<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Users table indexes
        if (!Schema::hasIndex('users', 'users_phone_number_index')) {
            Schema::table('users', fn(Blueprint $table) => $table->index('phone_number'));
        }
        if (!Schema::hasIndex('users', 'users_active_role_index')) {
            Schema::table('users', fn(Blueprint $table) => $table->index('active_role'));
        }
        if (!Schema::hasIndex('users', 'users_cluster_id_index')) {
            Schema::table('users', fn(Blueprint $table) => $table->index('cluster_id'));
        }

        // Campaigns table indexes
        if (!Schema::hasIndex('campaigns', 'campaigns_status_index')) {
            Schema::table('campaigns', fn(Blueprint $table) => $table->index('status'));
        }
        if (!Schema::hasIndex('campaigns', 'campaigns_initiator_id_index')) {
            Schema::table('campaigns', fn(Blueprint $table) => $table->index('initiator_id'));
        }
        if (!Schema::hasIndex('campaigns', 'campaigns_cluster_id_index')) {
            Schema::table('campaigns', fn(Blueprint $table) => $table->index('cluster_id'));
        }
        if (!Schema::hasIndex('campaigns', 'campaigns_deadline_index')) {
            Schema::table('campaigns', fn(Blueprint $table) => $table->index('deadline'));
        }

        // Campaign variants indexes
        if (!Schema::hasIndex('campaign_variants', 'campaign_variants_campaign_id_index')) {
            Schema::table('campaign_variants', fn(Blueprint $table) => $table->index('campaign_id'));
        }

        // Orders table indexes
        if (!Schema::hasIndex('orders', 'orders_user_id_index')) {
            Schema::table('orders', fn(Blueprint $table) => $table->index('user_id'));
        }
        if (!Schema::hasIndex('orders', 'orders_campaign_id_index')) {
            Schema::table('orders', fn(Blueprint $table) => $table->index('campaign_id'));
        }
        if (!Schema::hasIndex('orders', 'orders_payment_status_index')) {
            Schema::table('orders', fn(Blueprint $table) => $table->index('payment_status'));
        }
        if (!Schema::hasIndex('orders', 'orders_payment_method_index')) {
            Schema::table('orders', fn(Blueprint $table) => $table->index('payment_method'));
        }
        if (!Schema::hasIndex('orders', 'orders_is_taken_index')) {
            Schema::table('orders', fn(Blueprint $table) => $table->index('is_taken'));
        }
        if (!Schema::hasIndex('orders', 'orders_created_at_index')) {
            Schema::table('orders', fn(Blueprint $table) => $table->index('created_at'));
        }

        // Purchase orders indexes
        if (!Schema::hasIndex('purchase_orders', 'purchase_orders_initiator_id_index')) {
            Schema::table('purchase_orders', fn(Blueprint $table) => $table->index('initiator_id'));
        }
        if (!Schema::hasIndex('purchase_orders', 'purchase_orders_supplier_id_index')) {
            Schema::table('purchase_orders', fn(Blueprint $table) => $table->index('supplier_id'));
        }
        if (!Schema::hasIndex('purchase_orders', 'purchase_orders_campaign_id_index')) {
            Schema::table('purchase_orders', fn(Blueprint $table) => $table->index('campaign_id'));
        }
        if (!Schema::hasIndex('purchase_orders', 'purchase_orders_status_index')) {
            Schema::table('purchase_orders', fn(Blueprint $table) => $table->index('status'));
        }

        // Suppliers indexes
        if (!Schema::hasIndex('suppliers', 'suppliers_status_index')) {
            Schema::table('suppliers', fn(Blueprint $table) => $table->index('status'));
        }

        // Supplier offers indexes
        if (!Schema::hasIndex('supplier_offers', 'supplier_offers_supplier_id_index')) {
            Schema::table('supplier_offers', fn(Blueprint $table) => $table->index('supplier_id'));
        }
        if (!Schema::hasIndex('supplier_offers', 'supplier_offers_product_id_index')) {
            Schema::table('supplier_offers', fn(Blueprint $table) => $table->index('product_id'));
        }
        if (!Schema::hasIndex('supplier_offers', 'supplier_offers_status_index')) {
            Schema::table('supplier_offers', fn(Blueprint $table) => $table->index('status'));
        }

        // Supplier products indexes
        if (!Schema::hasIndex('supplier_products', 'supplier_products_supplier_id_index')) {
            Schema::table('supplier_products', fn(Blueprint $table) => $table->index('supplier_id'));
        }

        // Notifications indexes
        if (!Schema::hasIndex('notifications', 'notifications_user_id_index')) {
            Schema::table('notifications', fn(Blueprint $table) => $table->index('user_id'));
        }
        if (!Schema::hasIndex('notifications', 'notifications_read_at_index')) {
            Schema::table('notifications', fn(Blueprint $table) => $table->index('read_at'));
        }

        // Transaction logs indexes (skip if already exists)
        if (!Schema::hasIndex('transaction_logs', 'transaction_logs_user_id_index')) {
            Schema::table('transaction_logs', fn(Blueprint $table) => $table->index('user_id'));
        }
        if (!Schema::hasIndex('transaction_logs', 'transaction_logs_action_index')) {
            Schema::table('transaction_logs', fn(Blueprint $table) => $table->index('action'));
        }
        if (!Schema::hasIndex('transaction_logs', 'transaction_logs_target_type_index')) {
            Schema::table('transaction_logs', fn(Blueprint $table) => $table->index('target_type'));
        }
        if (!Schema::hasIndex('transaction_logs', 'transaction_logs_target_id_index')) {
            Schema::table('transaction_logs', fn(Blueprint $table) => $table->index('target_id'));
        }
        if (!Schema::hasIndex('transaction_logs', 'transaction_logs_created_at_index')) {
            Schema::table('transaction_logs', fn(Blueprint $table) => $table->index('created_at'));
        }
    }

    public function down(): void
    {
        // Safe rollback - only drop if exists
        $tables = [
            'users' => ['phone_number', 'active_role', 'cluster_id'],
            'campaigns' => ['status', 'initiator_id', 'cluster_id', 'deadline'],
            'campaign_variants' => ['campaign_id'],
            'orders' => ['user_id', 'campaign_id', 'payment_status', 'payment_method', 'is_taken', 'created_at'],
            'purchase_orders' => ['initiator_id', 'supplier_id', 'campaign_id', 'status'],
            'suppliers' => ['status'],
            'supplier_offers' => ['supplier_id', 'product_id', 'status'],
            'supplier_products' => ['supplier_id'],
            'notifications' => ['user_id', 'read_at'],
            'transaction_logs' => ['user_id', 'action', 'target_type', 'target_id', 'created_at'],
        ];

        foreach ($tables as $table => $indexes) {
            foreach ($indexes as $column) {
                $indexName = "{$table}_{$column}_index";
                try {
                    Schema::table($table, fn(Blueprint $table) => $table->dropIndex($indexName));
                } catch (\Exception $e) {
                    // Index doesn't exist, skip
                }
            }
        }
    }
};
