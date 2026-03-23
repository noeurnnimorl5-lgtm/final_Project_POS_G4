<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
     public function __construct(private ReportService $reportService) {}

    public function sales(Request $request)
    {
        $request->validate([
            'from' => 'required|date',
            'to'   => 'required|date|after_or_equal:from',
        ]);

        return response()->json([
            'summary'     => $this->reportService->salesSummary($request->from, $request->to),
            'daily'       => $this->reportService->dailySales($request->from, $request->to),
            'top_products'=> $this->reportService->topProducts($request->from, $request->to),
            'cashiers'    => $this->reportService->cashierPerformance($request->from, $request->to),
        ]);
    }
}
