<?php
namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request)
    {
        $query = Customer::withCount('orders');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('phone', 'like', '%' . $request->search . '%')
                  ->orWhere('email', 'like', '%' . $request->search . '%');
            });
        }

        return response()->json($query->latest()->paginate(20));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name'  => 'required|string|max:100',
            'phone' => 'nullable|string|max:20|unique:customers',
            'email' => 'nullable|email|unique:customers',
        ]);

        return response()->json(Customer::create($data), 201);
    }

    public function show(Customer $customer)
    {
        return response()->json(
            $customer->loadCount('orders')
                     ->load(['orders' => fn($q) => $q->latest()->limit(10)->with('payment')])
        );
    }

    public function update(Request $request, Customer $customer)
    {
        $data = $request->validate([
            'name'  => 'sometimes|string|max:100',
            'phone' => 'nullable|string|max:20|unique:customers,phone,' . $customer->id,
            'email' => 'nullable|email|unique:customers,email,' . $customer->id,
        ]);

        $customer->update($data);
        return response()->json($customer);
    }

    public function destroy(Customer $customer)
    {
        if ($customer->orders()->exists()) {
            return response()->json(
                ['message' => 'Cannot delete customer with existing orders.'], 422
            );
        }

        $customer->delete();
        return response()->json(['message' => 'Customer deleted.']);
    }
}
