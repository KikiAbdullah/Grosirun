<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Users table indexes
        Schema::table('users', function (Blueprint $table) {
            $table->index('phone_number');
            $table->index('active_role');
            $table->index('cluster_id');
        });

        // Campaigns table indexes
        Schema::table('campaigns', function (Blueprint $table) {
            $table->index('status');
            $table->index('initiator_id');
            $table->index('cluster_id');
            $table->index('deadline');
            $table->index(['status', 'cluster_id']);
        });

        // Campaign variants indexes
        Schema::table('campaign_variants', function (Blueprint $table) {
            $table->index('campaign_id');
        });

        // Orders table indexes
        Schema::table('orders', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('campaign_id');
            $table->index('payment_status');
            $table->index('payment_method');
            $table->index('is_taken');
            $table->index(['user_id', 'payment_status']);
            $table->index(['campaign_id', 'payment_status']);
            $table->index('created_at');
        });

        // Purchase orders indexes
        Schema::table('purchase_orders', function (Blueprint $table) {
            $table->index('initiator_id');
            $table->index('supplier_id');
            $table->index('campaign_id');
            $table->index('status');
            $table->index(['initiator_id', 'status']);
            $table->index(['supplier_id', 'status']);
        });

        // Suppliers indexes
        Schema::table('suppliers', function (Blueprint $table) {
            $table->index('status');
        });

        // Supplier offers indexes
        Schema::table('supplier_offers', function (Blueprint $table) {
            $table->index('supplier_id');
            $table->index('product_id');
            $table->index('status');
            $table->index(['supplier_id', 'status']);
        });

        // Supplier products indexes
        Schema::table('supplier_products', function (Blueprint $table) {
            $table->index('supplier_id');
        });

        // Notifications indexes
        Schema::table('notifications', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('read_at');
            $table->index(['user_id', 'read_at']);
        });

        // Transaction logs indexes
        Schema::table('transaction_logs', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('action');
            $table->index('target_type');
            $table->index('target_id');
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::table('users', fn(Blueprint $table) => $table->dropIndex(['phone_number', 'active_role', 'cluster_id']));
        Schema::table('campaigns', fn(Blueprint $table) => $table->dropIndex(['status', 'initiator_id', 'cluster_id', 'deadline', 'status_cluster_id']));
        Schema::table('campaign_variants', fn(Blueprint $table) => $table->dropIndex(['campaign_id']));
        Schema::table('orders', fn(Blueprint $table) => $table->dropIndex(['user_id', 'campaign_id', 'payment_status', 'payment_method', 'is_taken', 'user_id_payment_status', 'campaign_id_payment_status', 'created_at']));
        Schema::table('purchase_orders', fn(Blueprint $table) => $table->dropIndex(['initiator_id', 'supplier_id', 'campaign_id', 'status', 'initiator_id_status', 'supplier_id_status']));
        Schema::table('suppliers', fn(Blueprint $table) => $table->dropIndex(['status']));
        Schema::table('supplier_offers', fn(Blueprint $table) => $table->dropIndex(['supplier_id', 'product_id', 'status', 'supplier_id_status']));
        Schema::table('supplier_products', fn(Blueprint $table) => $table->dropIndex(['supplier_id']));
        Schema::table('notifications', fn(Blueprint $table) => $table->dropIndex(['user_id', 'read_at', 'user_id_read_at']));
        Schema::table('transaction_logs', fn(Blueprint $table) => $table->dropIndex(['user_id', 'action', 'target_type', 'target_id', 'created_at']));
    }
};
