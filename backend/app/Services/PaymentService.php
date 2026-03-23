<?php
namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\DB;

class PaymentService {
    public function process(Order $order, array $data): Payment {

        if ($order->status === 'completed') {
            throw new \Exception('Order is already paid.');
        }

        if ($order->status === 'cancelled') {
            throw new \Exception('Cannot pay a cancelled order.');
        }

        return DB::transaction(function () use ($order, $data) {
            $changeAmount = 0;
            if ($data['method'] === 'cash') {
                if ($data['amount'] < $order->total){
                    throw new \Exception('Cash amount is less than order total.');
                }
                $changeAmount = $data['amount'] - $order->total;
            }

            $payment = Payment::create([
                'order_id' => $order->id,
                'method' => $data['method'],
                'amount' => $data['amount'],
                'change_amount' => $changeAmount,
                'reference' => $data['reference'] ?? null,
                'paid_at' => now(),
            ]);
            $order->update(['status' => 'completed']);

            return $payment;
        });
    }
}
