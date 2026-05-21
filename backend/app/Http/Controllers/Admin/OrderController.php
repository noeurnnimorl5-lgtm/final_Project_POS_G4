<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Order::with(['user', 'items.product'])->latest();

        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('order_number', 'like', "%{$search}%")
                  ->orWhereHas('user', fn($u) => $u->where('name', 'like', "%{$search}%"));
            });
        }

        if ($request->filled('status')) {
            $query->where('status', $request->input('status'));
        }

        $orders = $query->paginate(15);

        return response()->json([
            'data' => $orders->map(fn($order) => [
                'id'              => $order->id,
                'user_id'         => $order->user_id ?? 0,
                'order_number'    => $order->order_number    ?? '',       // ✅ never null
                'cashier'         => $order->user?->name     ?? 'Unknown',// ✅ never null
                'user'            => $order->user
                                        ? ['id' => $order->user->id, 'name' => $order->user->name ?? '']
                                        : null,
                'date'            => $order->created_at?->format('Y-m-d H:i:s') ?? '',
                'subtotal'        => (float) ($order->subtotal        ?? 0),
                'discount'        => (float) ($order->discount        ?? 0),
                'grand_total'     => (float) ($order->grand_total     ?? 0),
                'amount_received' => (float) ($order->amount_received ?? 0),
                'change_amount'   => (float) ($order->change_amount   ?? 0),
                'payment_method'  => $order->payment_method ?? '',        // ✅ never null
                'status'          => $order->status          ?? 'pending',// ✅ never null
                'items_count'     => $order->items->count(),
                'items'           => [],
            ]),
            'meta' => [
                'total'        => $orders->total(),
                'current_page' => $orders->currentPage(),
                'last_page'    => $orders->lastPage(),
            ],
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $order = Order::with(['user', 'items.product'])->findOrFail($id);

        return response()->json([
            'data' => [
                'id'              => $order->id,
                'user_id'         => $order->user_id ?? 0,
                'order_number'    => $order->order_number    ?? '',
                'cashier'         => $order->user?->name     ?? 'Unknown',
                'user'            => $order->user
                                        ? ['id' => $order->user->id, 'name' => $order->user->name ?? '']
                                        : null,
                'date'            => $order->created_at?->format('Y-m-d H:i:s') ?? '',
                'subtotal'        => (float) ($order->subtotal        ?? 0),
                'discount'        => (float) ($order->discount        ?? 0),
                'grand_total'     => (float) ($order->grand_total     ?? 0),
                'amount_received' => (float) ($order->amount_received ?? 0),
                'change_amount'   => (float) ($order->change_amount   ?? 0),
                'payment_method'  => $order->payment_method ?? '',
                'status'          => $order->status          ?? 'pending',
                'items'           => $order->items->map(fn($item) => [
                    'id'            => $item->id,
                    'order_id'      => $item->order_id      ?? 0,
                    'product_id'    => $item->product_id    ?? 0,
                    'product_name'  => $item->product_name  ?? '',  // ✅ key matches fromJson
                    'product_price' => (float) ($item->product_price ?? 0), // ✅ key matches fromJson
                    'quantity'      => (int) ($item->quantity ?? 0),
                    'subtotal'      => (float) ($item->subtotal ?? 0),
                    'image'         => $item->product?->image_url ?? null,
                ]),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $order = Order::create([
            'user_id'         => $request->user()->id,
            'subtotal'        => 0,
            'discount'        => $request->input('discount', 0),
            'grand_total'     => 0,
            'payment_method'  => $request->input('payment_method', 'cash'),
            'amount_received' => $request->input('amount_received', 0),
            'change_amount'   => $request->input('change_amount', 0),
            'status'          => 'synced',
            'cashier'         => $request->user()->name,
            'date'            => now(),
        ]);

        $subtotal = 0;

        foreach ($request->input('items', []) as $item) {
            $product      = Product::findOrFail($item['product_id']);
            $quantity     = (int) $item['quantity'];
            $lineSubtotal = $product->price * $quantity;

            OrderItem::create([
                'order_id'      => $order->id,
                'product_id'    => $product->id,
                'product_name'  => $product->name,
                'product_price' => $product->price,
                'quantity'      => $quantity,
                'subtotal'      => $lineSubtotal,
            ]);

            $subtotal += $lineSubtotal;
        }

        $order->update([
            'subtotal'    => $subtotal,
            'grand_total' => $subtotal - $order->discount,
        ]);

        return response()->json([
            'message' => 'Order created successfully',
            'data'    => $order->load('items.product'),
        ]);
    }
}