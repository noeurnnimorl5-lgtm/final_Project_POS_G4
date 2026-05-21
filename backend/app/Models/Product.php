<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;
use Illuminate\Database\Eloquent\Builder;

class Product extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'category_id',
        'name',
        'slug',
        'description',
        'price',
        'stock',
        'image_url',
        'image_public_id',
        'rating',
        'is_active',
    ];

    protected $casts = [
        'price'     => 'decimal:2',
        'rating'    => 'decimal:1',
        'stock'     => 'integer',
        'is_active' => 'boolean',
    ];

    protected $appends = ['stock_status'];

    protected static function boot(): void
    {
        parent::boot();

        static::creating(function ($product) {
            $product->slug = Str::slug($product->name);
        });
    }

    /*
    |--------------------------------------------------------------------------
    | Relationships
    |--------------------------------------------------------------------------
    */

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function orderItems(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    /*
    |--------------------------------------------------------------------------
    | Accessors
    |--------------------------------------------------------------------------
    */

    public function getImageUrlAttribute($value): string
    {
        return $value ?: asset('images/placeholder.png');
    }

    public function getStockStatusAttribute(): string
    {
        if ($this->stock <= 0) {
            return 'out_of_stock';
        }

        if ($this->stock <= 5) {
            return 'low_stock';
        }

        return 'in_stock';
    }

    /*
    |--------------------------------------------------------------------------
    | Scopes
    |--------------------------------------------------------------------------
    */

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    public function scopeInCategory(Builder $query, ?string $categorySlug): Builder
    {
        if ($categorySlug && $categorySlug !== 'all') {
            return $query->whereHas('category', function ($q) use ($categorySlug) {
                $q->where('slug', $categorySlug);
            });
        }

        return $query;
    }

    public function scopeSearch(Builder $query, ?string $term): Builder
    {
        if ($term) {
            return $query->where(function ($q) use ($term) {
                $q->where('name', 'like', "%{$term}%")
                  ->orWhere('description', 'like', "%{$term}%");
            });
        }

        return $query;
    }
}
