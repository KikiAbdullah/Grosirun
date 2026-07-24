<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('campaigns', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('status', [
                'draft',
                'active',
                'target_reached',
                'po_submitted',
                'fulfillment',
                'completed',
                'expired',
                'cancelled'
            ])->default('draft');
            
            // Initiator info
            $table->foreignId('initiator_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('cluster_id')->constrained('clusters')->cascadeOnDelete();
            
            // Offer snapshot (immutable after creation)
            $table->json('offer_snapshot'); // Contains: supplier_id, product_name, unit, supplier_unit_price, tier, capacity, delivery_cost, validity
            $table->integer('supplier_unit_price'); // Price from supplier
            $table->integer('buyer_unit_price'); // Price to buyer
            $table->string('unit'); // kg, liter, piece, pack
            
            // Targets
            $table->integer('target_quantity'); // Target in base unit
            $table->integer('current_quantity')->default(0); // Current collected
            $table->integer('max_quantity')->nullable(); // Max capacity from offer
            
            // Timeline
            $table->timestamp('deadline');
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('distribution_completed_at')->nullable();
            
            // Distribution
            $table->string('location_distribution')->nullable();
            
            $table->timestamps();
            
            // Indexes for performance
            $table->index(['cluster_id', 'status', 'deadline']);
            $table->index(['initiator_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('campaigns');
    }
};
