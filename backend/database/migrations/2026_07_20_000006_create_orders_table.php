<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            
            // Relations
            $table->foreignId('campaign_id')->constrained('campaigns')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('campaign_variant_id')->constrained('campaign_variants')->cascadeOnDelete();
            $table->foreignId('cluster_id')->constrained('clusters')->cascadeOnDelete();
            
            // Order details
            $table->integer('quantity'); // Number of packages
            $table->integer('total_quantity'); // Total in base unit (quantity * package_quantity)
            $table->integer('total_price'); // Total price in IDR
            
            // Payment
            $table->enum('payment_method', ['cash', 'qris'])->default('cash');
            $table->enum('payment_status', [
                'pending',
                'waiting_qris',
                'paid',
                'rejected'
            ])->default('pending');
            
            // Proof (for QRIS)
            $table->string('proof_path')->nullable(); // S3 path
            $table->text('proof_url')->nullable(); // Temporary URL (1 hour)
            $table->timestamp('proof_uploaded_at')->nullable();
            
            // Validation
            $table->boolean('is_taken')->default(false); // Distribution checklist
            $table->timestamp('taken_at')->nullable();
            $table->foreignId('taken_by_initiator_id')->nullable()->constrained('users')->nullOnDelete();
            
            // Notes
            $table->text('validation_notes')->nullable();
            $table->text('rejection_reason')->nullable();
            
            // Idempotency
            $table->string('idempotency_key')->unique();
            
            $table->timestamps();
            
            // Indexes
            $table->index(['campaign_id', 'payment_status']);
            $table->index(['user_id', 'created_at']);
            $table->index(['cluster_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
