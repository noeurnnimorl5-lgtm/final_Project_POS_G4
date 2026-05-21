import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/dashboard_notifier.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/kpi_row.dart';
import 'widgets/sales_chart.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/top_products_table.dart';
import 'widgets/recent_activity.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Error: $err', style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
        data: (dashboardData) => _DashboardContent(data: dashboardData),
      ),
    );
  }
}

// ── Helpers (used by multiple widgets) ──────────────────────────────────────

List<double> parseWeeklySales(Map<String, dynamic> data) {
  final raw = data['weekly_sales'];
  if (raw is List) return raw.map((e) => (e as num).toDouble()).toList();
  return [1200, 1850, 1400, 2200, 1900, 2800, 2100];
}

List<Map<String, dynamic>> parseCategories(Map<String, dynamic> data) {
  final raw = data['category_breakdown'];
  if (raw is List) return List<Map<String, dynamic>>.from(raw);
  return [
    {'name': 'Food',   'value': 40.0, 'color': 0xFFFF6B00},
    {'name': 'Drinks', 'value': 25.0, 'color': 0xFF2196F3},
    {'name': 'Snacks', 'value': 20.0, 'color': 0xFF4CAF50},
    {'name': 'Others', 'value': 15.0, 'color': 0xFF9C27B0},
  ];
}

// ── Layout assembler ─────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          const SizedBox(height: 28),

          KpiRow(data: data),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SalesChart(weeklySales: parseWeeklySales(data)),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: CategoryPieChart(categories: parseCategories(data)),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TopProductsTable(
                  products: List.from(data['top_products'] ?? []),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: RecentActivity(
                  transactions: List.from(data['recent_transactions'] ?? []),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}