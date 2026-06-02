<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(): JsonResponse
    {
        // Today
        $todayOrders = Order::whereDate('created_at', today())->get();

        // Weekly sales (last 7 days, oldest → newest)
        $weeklySales = collect(range(6, 0))->map(function ($daysAgo) {
            return (float) Order::whereDate('created_at', today()->subDays($daysAgo))
                ->sum('grand_total');
        })->values()->toArray();

        // Category breakdown
        $categoryBreakdown = DB::table('order_items')
            ->join('products', 'order_items.product_id', '=', 'products.id')
            ->join('categories', 'products.category_id', '=', 'categories.id')
            ->select(
                'categories.name',
                'categories.color',
                DB::raw('SUM(order_items.subtotal) as value')
            )
            ->groupBy('categories.id', 'categories.name', 'categories.color')
            ->orderByDesc('value')
            ->get()
            ->map(fn($row) => [
                'name'  => $row->name,
                'value' => (float) $row->value,
                'color' => hexdec(ltrim($row->color ?? '#FF6B00', '#')),
            ])
            ->toArray();

        // Top products
        $topProducts = Product::withCount(['orderItems as sold' => fn($q) =>
            $q->selectRaw('sum(quantity)')])
            ->orderByDesc('sold')
            ->take(5)
            ->get()
            ->map(fn($p) => [
                'name'  => $p->name,
                'sold'  => $p->sold ?? 0,
                'price' => $p->price,
            ]);

        // Recent transactions
        $recentTransactions = Order::latest()
            ->take(10)
            ->get(['id', 'grand_total', 'created_at'])
            ->map(fn($o) => [
                'id'     => $o->id,
                'amount' => number_format($o->grand_total, 2),
                'date'   => $o->created_at->format('M d, Y'),
            ]);

        return response()->json([
            'data' => [
                'today_sales'          => number_format($todayOrders->sum('grand_total'), 2),
                'total_orders'         => $todayOrders->count(),
                'total_cashiers'       => User::where('role', 'cashier')->count(),
                'top_products'         => $topProducts,
                'weekly_sales'         => $weeklySales,
                'category_breakdown'   => $categoryBreakdown,
                'recent_transactions'  => $recentTransactions,
            ],
        ]);
    }
}