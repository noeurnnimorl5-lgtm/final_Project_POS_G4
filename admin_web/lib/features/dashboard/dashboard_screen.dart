import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/dashboard_notifier.dart';

// ─────────────────────────────────────────────────────────────
// Colour palette
// ─────────────────────────────────────────────────────────────
const _navy   = Color(0xFF1A1A2E);
const _orange = Color(0xFFFF6B00);
const _card   = Color(0xFFFFFFFF);
const _bg     = Color(0xFFF4F6FA);
const _muted  = Color(0xFF8A93A8);
const _green  = Color(0xFF22C55E);
const _blue   = Color(0xFF3B82F6);
const _purple = Color(0xFF8B5CF6);

// ─────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardNotifierProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _orange),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () =>
              ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
        ),
        data: (data) => _DashboardContent(
          data: data,
          onRefresh: () =>
              ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                color: Colors.red.shade400, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Failed to load dashboard',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _navy.withOpacity(.8))),
          const SizedBox(height: 6),
          Text(message,
              style: const TextStyle(fontSize: 12, color: _muted),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
List<double> _parseWeeklySales(Map<String, dynamic> data) {
  final raw = data['weekly_sales'];
  if (raw is List && raw.isNotEmpty) {
    return raw.map((e) => (e as num).toDouble()).toList();
  }
  return [1200, 1850, 1400, 2200, 1900, 2800, 2100];
}

List<Map<String, dynamic>> _parseCategories(Map<String, dynamic> data) {
  final raw = data['category_breakdown'];
  if (raw is List && raw.isNotEmpty) {
    return List<Map<String, dynamic>>.from(raw);
  }
  return [
    {'name': 'Food',   'value': 40.0, 'color': 0xFFFF6B00},
    {'name': 'Drinks', 'value': 25.0, 'color': 0xFF3B82F6},
    {'name': 'Snacks', 'value': 20.0, 'color': 0xFF22C55E},
    {'name': 'Others', 'value': 15.0, 'color': 0xFF8B5CF6},
  ];
}

// ─────────────────────────────────────────────────────────────
// Main content
// ─────────────────────────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;
  const _DashboardContent({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final weeklySales   = _parseWeeklySales(data);
    final categories    = _parseCategories(data);
    final topProducts   = List<Map<String, dynamic>>.from(data['top_products'] ?? []);
    final recentTx      = List<Map<String, dynamic>>.from(data['recent_transactions'] ?? []);

    return RefreshIndicator(
      color: _orange,
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            _Header(onRefresh: onRefresh),
            const SizedBox(height: 28),

            // ── KPI row ──────────────────────────────────────
            _KpiRow(data: data),
            const SizedBox(height: 28),

            // ── Charts row ───────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _SalesChartCard(weeklySales: weeklySales),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _CategoryBreakdownCard(categories: categories),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Tables row ───────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _TopProductsCard(products: topProducts),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _RecentTransactionsCard(transactions: recentTx),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onRefresh;
  const _Header({required this.onRefresh});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(height: 2),
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        // Right: date chip + refresh
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: _muted),
              const SizedBox(width: 6),
              Text(
                _formatDate(DateTime.now()),
                style: const TextStyle(
                    fontSize: 13, color: _navy, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _IconBtn(
          icon: Icons.refresh_rounded,
          tooltip: 'Refresh',
          onTap: onRefresh,
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: _navy),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KPI Row
// ─────────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _KpiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KpiCard(
          title: "Today's Sales",
          value: '\$${data['today_sales'] ?? '0.00'}',
          icon: Icons.attach_money_rounded,
          accent: _orange,
          trend: '+12.5%',
          trendUp: true,
        ),
        const SizedBox(width: 16),
        _KpiCard(
          title: 'Total Orders',
          value: '${data['total_orders'] ?? 0}',
          icon: Icons.receipt_long_rounded,
          accent: _blue,
          trend: '+8.2%',
          trendUp: true,
        ),
        const SizedBox(width: 16),
        _KpiCard(
          title: 'Total Cashiers',
          value: '${data['total_cashiers'] ?? 0}',
          icon: Icons.people_alt_rounded,
          accent: _purple,
          trend: 'Active',
          trendUp: true,
        ),
        const SizedBox(width: 16),
        _KpiCard(
          title: 'Avg Order Value',
          value: () {
            final sales  = double.tryParse(
                    (data['today_sales'] ?? '0').toString().replaceAll(',', '')) ??
                0.0;
            final orders = (data['total_orders'] ?? 0) as int;
            if (orders == 0) return '\$0.00';
            return '\$${(sales / orders).toStringAsFixed(2)}';
          }(),
          icon: Icons.show_chart_rounded,
          accent: _green,
          trend: '+3.1%',
          trendUp: true,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final String trend;
  final bool trendUp;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? _green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 12,
                        color: trendUp ? _green : Colors.red,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trendUp ? _green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _navy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: _muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sales Chart Card (bar chart)
// ─────────────────────────────────────────────────────────────
class _SalesChartCard extends StatelessWidget {
  final List<double> weeklySales;
  const _SalesChartCard({required this.weeklySales});

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = weeklySales.isEmpty
        ? 1.0
        : weeklySales.reduce((a, b) => a > b ? a : b);
    final todayIndex = DateTime.now().weekday - 1;

    return _CardWrapper(
      title: 'Weekly Sales',
      subtitle: 'Last 7 days overview',
      trailing: _LegendDot(color: _orange, label: 'Revenue'),
      child: SizedBox(
        height: 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(weeklySales.length, (i) {
            final ratio = maxVal > 0 ? weeklySales[i] / maxVal : 0.0;
            final isToday = i == todayIndex;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '\$${_compact(weeklySales[i])}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    Flexible(
                      child: FractionallySizedBox(
                        heightFactor: ratio.clamp(0.05, 1.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 60),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isToday
                                  ? [_orange, _orange.withOpacity(0.6)]
                                  : [
                                      _navy.withOpacity(0.15),
                                      _navy.withOpacity(0.06)
                                    ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[i % days.length],
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday ? _orange : _muted,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  String _compact(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 11, color: _muted)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Category Breakdown (horizontal bars)
// ─────────────────────────────────────────────────────────────
class _CategoryBreakdownCard extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  const _CategoryBreakdownCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(
        0, (s, c) => s + ((c['value'] as num?)?.toDouble() ?? 0));

    return _CardWrapper(
      title: 'Category Sales',
      subtitle: 'Revenue distribution',
      child: Column(
        children: categories.map((cat) {
          final value  = (cat['value'] as num?)?.toDouble() ?? 0;
          final ratio  = total > 0 ? value / total : 0.0;
          final color  = Color(cat['color'] as int? ?? 0xFFFF6B00);
          final name   = cat['name']?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _navy)),
                      ],
                    ),
                    Text(
                      '${(ratio * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _navy),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Top Products Table
// ─────────────────────────────────────────────────────────────
class _TopProductsCard extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const _TopProductsCard({required this.products});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Top Products',
      subtitle: 'Best selling items',
      child: Column(
        children: [
          // Table header
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: const [
                SizedBox(width: 32),
                Expanded(
                    flex: 3,
                    child: Text('Product',
                        style: TextStyle(
                            fontSize: 11,
                            color: _muted,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Sold',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: _muted,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Price',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            color: _muted,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const Divider(height: 1),

          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No product data',
                  style: TextStyle(color: _muted, fontSize: 13)),
            )
          else
            ...List.generate(products.length, (i) {
              final p     = products[i];
              final name  = p['name']?.toString() ?? '—';
              final sold  = p['sold']?.toString() ?? '0';
              final price = p['price'];
              final priceStr = price != null
                  ? '\$${double.tryParse(price.toString())?.toStringAsFixed(2) ?? price}'
                  : '—';

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? _orange.withOpacity(0.15)
                                : _navy.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: i == 0 ? _orange : _muted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Text(
                            name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _navy),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sold,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _green),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            priceStr,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _navy),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < products.length - 1)
                    const Divider(height: 1),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Recent Transactions
// ─────────────────────────────────────────────────────────────
class _RecentTransactionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  const _RecentTransactionsCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      title: 'Recent Transactions',
      subtitle: 'Latest orders',
      child: transactions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No transactions yet',
                    style: TextStyle(color: _muted, fontSize: 13)),
              ),
            )
          : Column(
              children: List.generate(transactions.length, (i) {
                final tx     = transactions[i];
                final id     = tx['id']?.toString() ?? '—';
                final amount = tx['amount']?.toString() ?? '0.00';
                final date   = tx['date']?.toString() ?? '';

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt_rounded,
                                size: 16, color: _orange),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #$id',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _navy),
                                ),
                                const SizedBox(height: 2),
                                Text(date,
                                    style: const TextStyle(
                                        fontSize: 11, color: _muted)),
                              ],
                            ),
                          ),
                          Text(
                            '\$$amount',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _navy),
                          ),
                        ],
                      ),
                    ),
                    if (i < transactions.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable card wrapper
// ─────────────────────────────────────────────────────────────
class _CardWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  const _CardWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}