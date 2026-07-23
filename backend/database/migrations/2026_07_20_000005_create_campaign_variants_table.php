<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('campaign_variants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('campaign_id')->constrained('campaigns')->cascadeOnDelete();
            $table->string('name'); // e.g., "5 Kg", "10 Kg", "25 Kg Sak"
            $table->integer('package_quantity'); // Quantity per package in base unit
            $table->integer('max_quantity'); // Max quantity available
            $table->integer('sold_quantity')->default(0); // Already sold
            $table->timestamps();
            
            $table->index(['campaign_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('campaign_variants');
    }
};
