<?php
namespace App\Http\Controllers\Cashier;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\PaymentService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(private PaymentService $paymentService) {}

    public function store(Request $request, Order $order)
    {
        $request->validate([
            'method'    => 'required|in:cash,card,qr',
            'amount'    => 'required|numeric|min:0',
            'reference' => 'nullable|string',
        ]);

        try {
            $payment = $this->paymentService->process($order, $request->all());
            return response()->json($payment->load('order'), 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}
