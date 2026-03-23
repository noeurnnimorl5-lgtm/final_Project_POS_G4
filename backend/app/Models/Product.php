<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    //
    use hasFactory;

    protected $fillable = [
        'category_id', 'name', 'description',
        'price', 'stock', 'image_url', 'barcode', 'is_active'
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'stock' => 'integer',
        'is_active' => 'boolean',
    ];

    public function category(){
        return $this->belongsTo(Category::class);
    }

    public function ordeItems() {
        return $this->hasMany(OrderItem::class);
    }

    public function decrementStock(int $quantity) {
        $this->decrement('stock', $quantity);
    }
}
