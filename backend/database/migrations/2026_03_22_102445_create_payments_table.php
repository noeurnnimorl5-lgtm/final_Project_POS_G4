<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constained()->onDelete('cascade');
            $table->enum('method', ['cash', 'card', 'qr'])->default('cash');
            $table->decimal('amount', 12, 2);
            $table->decimal('change_amount', 12, 2)->default(0);
            $table->string('reference')->nullable(); // card/QR transaction ref
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
