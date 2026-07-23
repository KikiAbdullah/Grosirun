<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('phone_number')->unique();
            $table->string('fcm_token')->nullable();
            $table->enum('role', ['buyer', 'initiator', 'seller', 'admin'])->default('buyer');
            $table->enum('active_role', ['buyer', 'initiator', 'seller', 'admin'])->nullable();
            $table->foreignId('cluster_id')->nullable()->constrained('clusters')->nullOnDelete();
            $table->timestamp('consent_at')->nullable();
            $table->string('consent_version')->nullable();
            $table->timestamp('tos_accepted_at')->nullable();
            $table->string('tos_version')->nullable();
            $table->boolean('privacy_policy_accepted')->default(false);
            $table->timestamp('privacy_policy_accepted_at')->nullable();
            $table->boolean('is_suspended')->default(false);
            $table->timestamp('suspended_at')->nullable();
            $table->string('suspension_reason')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
