<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Supplier (organization)
        Schema::create('suppliers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('address')->nullable();
            $table->json('service_areas')->nullable(); // Array of cluster codes
            $table->string('contact_business')->nullable();
            $table->enum('verification_status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->text('verification_notes')->nullable();
            $table->timestamps();
        });

        // Supplier members (seller users)
        Schema::create('supplier_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('supplier_id')->constrained('suppliers')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('member_role', ['owner', 'sales', 'warehouse']);
            $table->timestamps();
            
            $table->unique(['supplier_id', 'user_id']);
        });

        // Supplier products
        Schema::create('supplier_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('supplier_id')->constrained('suppliers')->cascadeOnDelete();
            $table->string('name');
            $table->string('base_unit'); // kg, liter, piece, pack
            $table->text('description')->nullable();
            $table->string('image_path')->nullable();
            $table->timestamps();
        });

        // Supplier offers
        Schema::create('supplier_offers', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('supplier_id')->constrained('suppliers')->cascadeOnDelete();
            $table->foreignId('product_id')->constrained('supplier_products')->cascadeOnDelete();
            $table->foreignId('created_by_id')->constrained('users')->cascadeOnDelete();
            
            // Offer details
            $table->integer('minimum_quantity'); // Minimum order in base unit
            $table->integer('capacity'); // Max capacity in base unit
            $table->json('tier_prices'); // Array of {min_qty, price_per_unit}
            $table->json('service_areas'); // Array of cluster codes
            $table->integer('delivery_cost')->default(0);
            $table->timestamp('valid_until');
            
            // Status
            $table->enum('status', ['draft', 'pending_moderation', 'active', 'expired', 'rejected'])->default('draft');
            $table->text('moderation_notes')->nullable();
            
            $table->timestamps();
            
            $table->index(['supplier_id', 'status']);
            $table->index(['status', 'valid_until']);
        });

        // Purchase orders
        Schema::create('purchase_orders', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            
            // Relations
            $table->foreignId('campaign_id')->constrained('campaigns')->cascadeOnDelete();
            $table->foreignId('offer_id')->constrained('supplier_offers')->cascadeOnDelete();
            $table->foreignId('supplier_id')->constrained('suppliers')->cascadeOnDelete();
            $table->foreignId('initiator_id')->constrained('users')->cascadeOnDelete();
            
            // Order details
            $table->integer('total_quantity'); // Total in base unit
            $table->integer('unit_price'); // Price per unit from offer
            $table->integer('subtotal'); // total_quantity * unit_price
            $table->integer('delivery_cost')->default(0);
            $table->integer('total_amount'); // subtotal + delivery_cost
            
            // Payment
            $table->string('payment_proof_path')->nullable(); // S3 path
            $table->timestamp('payment_confirmed_at')->nullable();
            
            // Status
            $table->enum('status', [
                'draft',
                'submitted',
                'accepted',
                'awaiting_payment',
                'paid',
                'processing',
                'shipped',
                'delivered',
                'rejected',
                'cancelled'
            ])->default('draft');
            
            // Documents
            $table->string('invoice_path')->nullable();
            $table->string('surat_jalan_path')->nullable();
            
            // Rejection
            $table->text('rejection_reason')->nullable();
            
            // Timeline
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('shipped_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            
            $table->timestamps();
            
            $table->index(['supplier_id', 'status']);
            $table->index(['initiator_id', 'status']);
        });

        // Purchase order documents (additional docs)
        Schema::create('purchase_order_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('purchase_order_id')->constrained('purchase_orders')->cascadeOnDelete();
            $table->string('document_type'); // invoice, surat_jalan, photo, etc.
            $table->string('file_path'); // S3 path
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('purchase_order_documents');
        Schema::dropIfExists('purchase_orders');
        Schema::dropIfExists('supplier_offers');
        Schema::dropIfExists('supplier_products');
        Schema::dropIfExists('supplier_members');
        Schema::dropIfExists('suppliers');
    }
};
