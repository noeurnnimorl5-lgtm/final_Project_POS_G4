import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';
    final items = order['items'] as List? ?? [];
    final grandTotal = order['grand_total'] ?? '0.00';
    final date = order['date'] ?? '';
    final orderNumber = order['order_number'] ?? '#${order['id']}';
    final paymentMethod = order['payment_method'] ?? '';

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'synced':
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Completed';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'refunded':
        statusColor = Colors.red;
        statusText = 'Refunded';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFFE65100);
        statusText = 'Pending';
        statusIcon = Icons.schedule_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Icon ──
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFFF6B00),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // ── Order info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order number — truncate long hex IDs
                  Text(
                    _formatOrderNumber(orderNumber),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text('${items.length} items',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded,
                          size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          _formatDate(date),
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Total + status ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$$grandTotal',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFFFF6B00),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 3),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Shorten old hex order numbers ──
  String _formatOrderNumber(String number) {
    // New format: ORD-20240605-001 → keep as-is
    if (RegExp(r'ORD-\d{8}-\d+').hasMatch(number)) return number;
    // Old hex format: ORD-6A213B2B4B854 → ORD-···854
    if (number.length > 12) {
      return '${number.substring(0, 4)}···${number.substring(number.length - 4)}';
    }
    return number;
  }

  // ── Format date nicely ──
  String _formatDate(String date) {
    // Input: "04/06/2026 08:45" → "Jun 4, 08:45"
    try {
      final parts = date.split(' ');
      if (parts.length < 2) return date;
      final dateParts = parts[0].split('/');
      if (dateParts.length < 3) return date;
      final months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      final month = months[int.parse(dateParts[1]) - 1];
      final day = int.parse(dateParts[0]);
      final time = parts[1];
      return '$month $day, $time';
    } catch (_) {
      return date;
    }
  }
}