import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Donut chart breaking down sales by product category.
class CategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  const CategoryPieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final total = categories.fold(
        0.0, (sum, c) => sum + (c['value'] as num).toDouble());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales by Category',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          const Text('This week breakdown',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          _buildDonut(total),
          const SizedBox(height: 20),
          ..._buildLegend(total),
        ],
      ),
    );
  }

  Widget _buildDonut(double total) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: CustomPaint(
          painter: _PieChartPainter(categories: categories, total: total),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Text('Total',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLegend(double total) {
    return categories.map((c) {
      final pct   = total == 0 ? 0.0 : (c['value'] as num) / total * 100;
      final color = Color(c['color'] as int);

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(c['name'] as String,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('${pct.toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
          ],
        ),
      );
    }).toList();
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  final double total;
  const _PieChartPainter({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center      = Offset(size.width / 2, size.height / 2);
    final radius      = size.width / 2;
    final innerRadius = radius * 0.62;
    const gap         = 0.04;
    double startAngle = -math.pi / 2;

    for (final cat in categories) {
      final value      = (cat['value'] as num).toDouble();
      final sweepAngle =
          total == 0 ? 0.0 : (value / total) * 2 * math.pi - gap;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color      = Color(cat['color'] as int)
          ..style      = PaintingStyle.stroke
          ..strokeWidth = radius - innerRadius
          ..strokeCap  = StrokeCap.butt,
      );
      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => true;
}

// ── Shared decoration ────────────────────────────────────────────────────────

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.07),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ],
);