import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated bar chart showing revenue for each day of the current week.
class SalesChart extends StatelessWidget {
  final List<double> weeklySales;
  const SalesChart({super.key, required this.weeklySales});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxVal = weeklySales.isEmpty ? 1.0 : weeklySales.reduce(math.max);
    final total  = weeklySales.fold(0.0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(total),
          const SizedBox(height: 24),
          _buildBars(maxVal),
        ],
      ),
    );
  }

  Widget _buildHeader(double total) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Sales',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            SizedBox(height: 2),
            Text('Revenue overview',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Total: \$${total.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFF6B00)),
          ),
        ),
      ],
    );
  }

  Widget _buildBars(double maxVal) {
    // Fixed heights for the non-bar elements so we can compute exact bar space.
    const valueLabelHeight = 14.0; // value text
    const valueLabelGap    = 4.0;  // gap between label and bar
    const dayLabelGap      = 8.0;  // gap between bar and day text
    const dayLabelHeight   = 14.0; // day text
    const totalFixed =
        valueLabelHeight + valueLabelGap + dayLabelGap + dayLabelHeight;
    const totalHeight = 200.0; // overall SizedBox height — roomy enough
    const maxBarHeight = totalHeight - totalFixed;

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(weeklySales.length, (i) {
          final val     = weeklySales[i];
          final ratio   = maxVal == 0 ? 0.0 : val / maxVal;
          final barH    = maxBarHeight * ratio;
          final isToday = i == DateTime.now().weekday - 1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,   // ← shrink-wraps; no overflow
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label — always same height so bars align at bottom
                  SizedBox(
                    height: valueLabelHeight,
                    child: Text(
                      '\$${val.toStringAsFixed(0)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? const Color(0xFFFF6B00)
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: valueLabelGap),
                  // Bar
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600 + (i * 80)),
                    curve: Curves.easeOutCubic,
                    height: barH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isToday
                            ? [
                                const Color(0xFFFF6B00),
                                const Color(0xFFFF8C42),
                              ]
                            : [
                                const Color(0xFF1A1A2E).withOpacity(0.15),
                                const Color(0xFF1A1A2E).withOpacity(0.08),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: dayLabelGap),
                  // Day label
                  SizedBox(
                    height: dayLabelHeight,
                    child: Text(
                      i < _days.length ? _days[i] : '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday
                            ? const Color(0xFFFF6B00)
                            : Colors.grey[400],
                        fontWeight:
                            isToday ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
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