import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? reportData;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getReport();
      setState(() {
        reportData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Refresh only
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loadReport,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
                ),
              )
            else if (reportData == null)
              const Expanded(
                child: Center(child: Text('Failed to load report data')),
              )
            else ...[
              // Summary Cards
              Row(
                children: [
                  _summaryCard(
                    'Total Revenue',
                    '\$${reportData!['total_revenue'] ?? '0.00'}',
                    Icons.attach_money,
                    const Color(0xFFFF6B00),
                  ),
                  const SizedBox(width: 16),
                  _summaryCard(
                    'Total Orders',
                    '${reportData!['total_orders'] ?? 0}',
                    Icons.receipt_long,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 16),
                  _summaryCard(
                    'Total Products',
                    '${reportData!['total_products'] ?? 0}',
                    Icons.inventory_2,
                    const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 16),
                  _summaryCard(
                    'Total Users',
                    '${reportData!['total_users'] ?? 0}',
                    Icons.people,
                    const Color(0xFF9C27B0),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildTopProductsTable()),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildRecentOrders()),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(child: _buildDailyRevenueTable()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsTable() {
    final products = (reportData!['top_products'] as List<dynamic>?) ?? [];
    return _buildTable(
      title: 'Top Selling Products',
      headers: const ['Product', 'Qty Sold', 'Revenue'],
      rows: products
          .map(
            (p) => [
              (p['name'] ?? '').toString(),
              (p['total_quantity'] ?? 0).toString(),
              '\$${(p['total_revenue'] ?? '0.00').toString()}',
            ],
          )
          .toList(),
    );
  }

  Widget _buildRecentOrders() {
    final orders = (reportData!['recent_orders'] as List<dynamic>?) ?? [];
    return _buildTable(
      title: 'Recent Orders',
      headers: const ['Order ID', 'Date', 'Amount'],
      rows: orders
          .map(
            (o) => [
              '#${(o['id'] ?? '').toString()}',
              (o['created_at'] ?? '').toString(),
              '\$${(o['total_amount'] ?? '0.00').toString()}',
            ],
          )
          .toList(),
    );
  }

  Widget _buildDailyRevenueTable() {
    final daily = (reportData!['daily_revenue'] as List<dynamic>?) ?? [];
    return _buildTable(
      title: 'Daily Revenue',
      headers: const ['Date', 'Orders', 'Revenue'],
      rows: daily
          .map(
            (d) => [
              (d['date'] ?? '').toString(),
              (d['total_orders'] ?? 0).toString(),
              '\$${(d['total_revenue'] ?? '0.00').toString()}',
            ],
          )
          .toList(),
    );
  }

  Widget _buildTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: headers
                .map(
                  (h) => Expanded(
                    child: Text(
                      h,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
          const Divider(),
          Expanded(
            child: rows.isEmpty
                ? const Center(child: Text('No data available'))
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: row
                              .map(
                                (cell) => Expanded(
                                  child: Text(
                                    cell,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
