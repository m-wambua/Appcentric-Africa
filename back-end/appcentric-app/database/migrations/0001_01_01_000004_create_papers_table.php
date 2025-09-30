<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('papers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained()->onDelete('cascade');
            $table->integer('year');
            $table->string('title');
            $table->text('description')->nullable();
            $table->timestamps();
            
            $table->index(['subject_id', 'year']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('papers');
    }
};