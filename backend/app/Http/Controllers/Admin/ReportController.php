<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index()
    {
        return response()->json([
            'total_revenue'  => number_format(Order::sum('grand_total') ?? 0, 2),
            'total_orders'   => Order::count(),
            'total_products' => Product::count(),
            'total_users'    => User::count(),

            'top_products' => OrderItem::select(
                                'product_id',
                                DB::raw('SUM(quantity) as total_quantity'),
                                DB::raw('SUM(subtotal) as total_revenue')
                              )
                              ->with('product:id,name')
                              ->groupBy('product_id')
                              ->orderByDesc('total_quantity')
                              ->limit(10)
                              ->get()
                              ->map(fn($item) => [
                                  'name'           => optional($item->product)->name ?? 'Unknown',
                                  'total_quantity' => $item->total_quantity,
                                  'total_revenue'  => number_format($item->total_revenue ?? 0, 2),
                              ]),

            'recent_orders' => Order::latest()
                                ->limit(10)
                                ->get(['id', 'grand_total', 'created_at'])
                                ->map(fn($o) => [
                                    'id'           => $o->id,
                                    'total_amount' => number_format($o->grand_total ?? 0, 2),
                                    'created_at'   => $o->created_at->format('M d, Y'),
                                ]),

            'daily_revenue' => Order::select(
                                DB::raw('DATE(created_at) as date'),
                                DB::raw('SUM(grand_total) as total_revenue'),
                                DB::raw('COUNT(*) as total_orders')
                              )
                              ->groupBy(DB::raw('DATE(created_at)'))
                              ->orderBy('date', 'desc')
                              ->get()
                              ->map(fn($row) => [
                                  'date'          => $row->date,
                                  'total_revenue' => number_format($row->total_revenue ?? 0, 2),
                                  'total_orders'  => $row->total_orders,
                              ]),
        ]);
    }
}