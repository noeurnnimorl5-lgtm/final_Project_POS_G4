<?php
namespace App\Services;

use App\Models\Order;
use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderService {
    public function create(array $data, int $userId): Order
    {
        return DB::transaction(function () use ($data, $userId) {

            // 1. Validate stock for all items first
            foreach ($data['items'] as $item) {
                $product = Product::findOrFail($item['product_id']);
                if ($product->stock < $item['quantity']) {
                    throw new \Exception("Insufficient stock for: {$product->name}");
                }
            }

            // 2. Calculate totals
            $subtotal = 0;
            $itemsToInsert = [];

            foreach ($data['items'] as $item) {
                $product   = Product::findOrFail($item['product_id']);
                $lineTotal = $product->price * $item['quantity'];
                $subtotal += $lineTotal;

                $itemsToInsert[] = [
                    'product_id' => $product->id,
                    'quantity'   => $item['quantity'],
                    'unit_price' => $product->price,
                    'subtotal'   => $lineTotal,
                ];
            }

            $tax      = $subtotal * ($data['tax_rate'] ?? 0);
            $discount = $data['discount'] ?? 0;
            $total    = $subtotal + $tax - $discount;

            // 3. Create order
            $order = Order::create([
                'user_id'      => $userId,
                'customer_id'  => $data['customer_id'] ?? null,
                'order_number' => $this->generateOrderNumber(),
                'status'       => 'pending',
                'subtotal'     => $subtotal,
                'tax'          => $tax,
                'discount'     => $discount,
                'total'        => $total,
                'note'         => $data['note'] ?? null,
                'local_id'     => $data['local_id'] ?? null,
            ]);

            // 4. Insert items
            $order->items()->createMany($itemsToInsert);

            // 5. Decrement stock
            foreach ($data['items'] as $item) {
                Product::find($item['product_id'])->decrementStock($item['quantity']);
            }

            return $order->load('items.product', 'customer');
        });
    }
    public function cancel(Order $order): Order {
        if ($order->status === 'completed') {
            throw new \Exception('Cannot cancel a completed order.');
        }

        return DB::transaction(function () use ($order) {
            // Restore stock
            foreach ($order->items as $item) {
                $item->product->increment('stock', $item->quantity);
            }
            $order->update(['status' => 'cancelled']);
            return $order;
        });
    }

    // For offline sync - batch for Mobile
    public function syncForMobile(array $orders, int $userId): array {
        $results = [];
        foreach ($orders as $orderData) {
            // Skip if already synced (same local_id exists)
            if (Order::where('local_id', $orderData['local_id'])->exists()) {
                $existing = Order::where('local_id', $orderData['local_id'])->first();
                $results[] = [
                    'local_id' => $orderData['local_id'],
                    'server_id' => $existing->id,
                    'status' => 'already_exist'
                    ];
                continue;
            }
            try {
                $order = $this->create($orderData, $userId);
                $results[] = [
                    'local_id' => $orderData['local_id'],
                    'server_id' => $order->id,
                    'status' => 'synced'
                    ];
            } catch (\Exception $e) {
                $results[] = [
                    'local_id' => $orderData['local_id'],
                    'server_id' => null,
                    'status' => 'failed',
                    'error' => $e->getMessage()
                ];
            }
        }
        return $results;
    }

    private function generateOrderNumber(): string {
        $date = now()->format('Ymd');
        $sequence = Order::whereDate('created_at', today())->count() + 1;
        return 'ORD-' .$date . '-' . str_pad($sequence, 4, '0', STR_PAD_LEFT);
    }

}

