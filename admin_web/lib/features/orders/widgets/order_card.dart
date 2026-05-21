import 'package:flutter/material.dart';
import '../../../data/models/order.dart';
import 'order_status_badge.dart';
import 'payment_badge.dart';

/// One row in the orders list. Tapping opens the detail sheet.
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF0F0F5), width: 1),
            ),
          ),
          child: Row(
            children: [
              // ── Order number + cashier ──
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFFFF6B00),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.user?.name.isNotEmpty == true
                                ? order.user!.name
                                : (order.cashier.isNotEmpty
                                      ? order.cashier
                                      : 'Unknown'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Date ──
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(order.date),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),

              // ── Items count ──
              Expanded(
                child: Text(
                  '${order.itemsCount} items', // ✅ was: order.items.length
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Payment ──
              Expanded(
                flex: 2,
                child: PaymentBadge(method: order.paymentMethod),
              ),

              // ── Grand total ──
              Expanded(
                flex: 2,
                child: Text(
                  '\$${order.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(width: 16),

              // ── Status ──
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OrderStatusBadge(status: order.status),
                ),
              ),

              const SizedBox(width: 8),

              // ── Chevron ──
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');

    return '${months[date.month - 1]} ${date.day}, $h:$min';
  }
}
