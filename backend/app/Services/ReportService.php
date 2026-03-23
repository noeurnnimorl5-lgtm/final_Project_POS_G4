<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Support\Facades\DB;

class ReportService {
    public function salesSummary(string $from, string $to): array {
        $orders = Order::where('status', 'completed')
                ->whereBetween('created_at', [$from . '00:00:00', $to .' 23:59:59'])
                ->get();

        return [
            'total_orders' => $orders->count(),
            'total_revenue' => $orders->sum('total'),
            'total_tax' => $orders->sum('tax'),
            'total_discount' => $orders->sum('discount'),
        ];
    }

    public function dailySales(string $from, string $to, int $limit = 10): array {
        return OrderItem::whereHas('order', function ($q) use ($from, $to) {
            $q->where('status', 'completed')
                ->whereBetween('created_at', [$from . '00:00:00', $to . ' 23:59:59']);
        })
        ->select('product_id', DB::raw('SUM(quantity) as total_qty'), DB::raw('SUM(subtotal) as total_revenue'))
        ->groupBy('product_id')
        ->orderByDesc('total_qty')
        ->limit($limit)
        ->with('product::id,name,price')
        ->get()
        ->toArray();
    }

    public function cashierPerformance(string $from, string $to): array {
        return Order::where('status', 'completed')
            ->whereBetween('created_at', [$from . '00:00:00', $to . '23:59:59'])
            ->selectRaw('user_id, COUNT(*) as total_orders, SUM(total) as toatl_revenue')
            ->groupBy('user_id')
            ->with('user:id,name')
            ->get()
            ->toArray();
    }
    
    public function topProducts(string $from, string $to, int $limit = 10): array
    {
        return OrderItem::whereHas('order', function ($q) use ($from, $to) {
                $q->where('status', 'completed')
                ->whereBetween('created_at', [$from . ' 00:00:00', $to . ' 23:59:59']);
            })
            ->select(
                'product_id',
                DB::raw('SUM(quantity) as total_qty'),
                DB::raw('SUM(subtotal) as total_revenue')
            )
            ->groupBy('product_id')
            ->orderByDesc('total_qty')
            ->limit($limit)
            ->get()
            ->map(function ($item) {
                $product = \App\Models\Product::select('id', 'name', 'price')->find($item->product_id);
                return [
                    'product_id'    => $item->product_id,
                    'total_qty'     => $item->total_qty,
                    'total_revenue' => $item->total_revenue,
                    'product'       => $product,
                ];
            })
            ->toArray();
    }
}
