import 'package:flutter/material.dart';

/// Row of four KPI summary cards at the top of the dashboard.
class KpiRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const KpiRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KpiCard(
          label: "Today's Revenue",
          value: '\$${data['today_sales'] ?? '0.00'}',
          icon: Icons.attach_money_rounded,
          color: const Color(0xFFFF6B00),
          trend: '+12.5%',
          trendUp: true,
          subtitle: 'vs yesterday',
        ),
        const SizedBox(width: 16),
        _KpiCard(
          label: 'Total Orders',
          value: '${data['total_orders'] ?? 0}',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF2196F3),
          trend: '+8.2%',
          trendUp: true,
          subtitle: 'this week',
        ),
        const SizedBox(width: 16),
        _KpiCard(
          label: 'Active Cashiers',
          value: '${data['total_cashiers'] ?? 0}',
          icon: Icons.people_rounded,
          color: const Color(0xFF4CAF50),
          trend: '2 online',
          trendUp: true,
          subtitle: 'now',
        ),
        const SizedBox(width: 16),
        _KpiCard(
          label: 'Avg. Order Value',
          value: '\$${data['avg_order_value'] ?? '0.00'}',
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF9C27B0),
          trend: '-3.1%',
          trendUp: false,
          subtitle: 'vs last week',
        ),
      ],
    );
  }
}

// ── Private card ─────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendUp;
  final String subtitle;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendUp,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                // Trend badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendUp
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trendUp
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 11,
                        color: trendUp ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: trendUp ? Colors.green : Colors.red,
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
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}