<?php
namespace App\Http\Controllers\Cashier;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\OrderService;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(private OrderService $orderService) {}

    public function store(Request $request)
    {
        $request->validate([
            'items'              => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity'   => 'required|integer|min:1',
            'customer_id'        => 'nullable|exists:customers,id',
            'discount'           => 'nullable|numeric|min:0',
            'tax_rate'           => 'nullable|numeric|min:0|max:1',
            'note'               => 'nullable|string',
            'local_id'           => 'nullable|string',
        ]);

        try {
            $order = $this->orderService->create($request->all(), $request->user()->id);
            return response()->json($order, 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function index(Request $request)
    {
        // Cashier sees only their own orders today
        return response()->json(
            Order::with('items.product', 'payment')
                ->where('user_id', $request->user()->id)
                ->whereDate('created_at', today())
                ->latest()
                ->get()
        );
    }

    // Batch sync from offline mobile
    public function sync(Request $request)
    {
        $request->validate([
            'orders'                       => 'required|array',
            'orders.*.local_id'            => 'required|string',
            'orders.*.items'               => 'required|array',
            'orders.*.items.*.product_id'  => 'required|exists:products,id',
            'orders.*.items.*.quantity'    => 'required|integer|min:1',
        ]);

        $results = $this->orderService->syncFromMobile($request->orders, $request->user()->id);
        return response()->json(['results' => $results]);
    }
}
