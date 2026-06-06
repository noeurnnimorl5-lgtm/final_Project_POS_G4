import 'package:flutter/material.dart';
import '../../../data/models/order.dart';
import 'order_status_badge.dart';
import 'payment_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFFFF8F5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF0F0F5)),
            ),
          ),
          child: Row(
            children: [
              // ── Order number + cashier ──────────────────
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFFFF6B00),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.user?.name.isNotEmpty == true
                                ? order.user!.name
                                : order.cashier.isNotEmpty
                                    ? order.cashier
                                    : 'Unknown',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Date ────────────────────────────────────
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDay(order.date),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      _formatTime(order.date),
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              // ── Items count ──────────────────────────────
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${order.itemsCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // ── Payment ──────────────────────────────────
              Expanded(
                flex: 2,
                child: PaymentBadge(method: order.paymentMethod),
              ),

              // ── Grand total ──────────────────────────────
              Expanded(
                flex: 2,
                child: Text(
                  '\$${order.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(width: 16),

              // ── Status ───────────────────────────────────
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OrderStatusBadge(status: order.status),
                ),
              ),

              const SizedBox(width: 8),

              // ── Chevron ──────────────────────────────────
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Jun 5, 2024 ──
  String _formatDay(DateTime? date) {
    if (date == null) return '—';
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ── 08:45 ──
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}