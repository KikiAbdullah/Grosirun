<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaction_logs', function (Blueprint $table) {
            $table->id();
            $table->string('type'); // validation, rejection, override, cancel_campaign, proof_upload, etc.
            $table->morphs('loggable'); // Polymorphic: order, campaign, user, etc.
            $table->foreignId('initiator_id')->nullable()->constrained('users')->nullOnDelete();
            $table->text('notes')->nullable();
            $table->json('before_data')->nullable(); // Snapshot before change
            $table->json('after_data')->nullable(); // Snapshot after change
            $table->string('ip_address')->nullable();
            $table->string('user_agent')->nullable();
            $table->timestamps();
            
            $table->index(['type', 'created_at']); // loggable index already created by morphs()
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaction_logs');
    }
};
