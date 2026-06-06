<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'order_number',
        'subtotal',
        'discount',
        'grand_total',
        'payment_method',
        'amount_received',
        'change_amount',
        'status',
        'cashier',
        'date',
    ];

    protected $casts = [
        'subtotal'        => 'decimal:2',
        'discount'        => 'decimal:2',
        'grand_total'     => 'decimal:2',
        'amount_received' => 'decimal:2',
        'change_amount'   => 'decimal:2',
        'date'            => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    protected static function boot(): void
    {
        parent::boot();
        // static::creating(function ($order) {
        //     $order->order_number = 'ORD-' . strtoupper(uniqid());
        // });
        static::creating(function ($order) {
        // ✅ Format: ORD-20240605-001 (date + daily sequence)
        $date = now()->format('Ymd');
        $count = static::whereDate('created_at', today())->count() + 1;
        $order->order_number = 'ORD-' . $date . '-' . str_pad($count, 3, '0', STR_PAD_LEFT);
    });
    }
}
