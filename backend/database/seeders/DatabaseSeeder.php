<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // Clean categories and products before re-seeding
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        \App\Models\Product::truncate();
        \App\Models\Category::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Categories
        $food   = \App\Models\Category::create(['name' => 'Food',   'slug' => 'food',   'is_active' => true]);
        $drinks = \App\Models\Category::create(['name' => 'Drinks', 'slug' => 'drinks', 'is_active' => true]);
        $snacks = \App\Models\Category::create(['name' => 'Snacks', 'slug' => 'snacks', 'is_active' => true]);

        // Products
        \App\Models\Product::create([
            'category_id' => $food->id,
            'name'        => 'Fried Rice',
            'price'       => 5.00,
            'stock'       => 100,
            'is_active'   => true,
        ]);
        \App\Models\Product::create([
            'category_id' => $drinks->id,
            'name'        => 'Iced Coffee',
            'price'       => 2.50,
            'stock'       => 200,
            'is_active'   => true,
        ]);
        \App\Models\Product::create([
            'category_id' => $snacks->id,
            'name'        => 'Chips',
            'price'       => 1.50,
            'stock'       => 150,
            'is_active'   => true,
        ]);
    }
}
