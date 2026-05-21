import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'pending';

    Color statusColor;
    String statusText;

    switch (status) {
      case 'synced':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'refunded':
        statusColor = Colors.red;
        statusText = 'Refunded';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
    }

    final items = order['items'] as List? ?? [];
    final grandTotal = order['grand_total'] ?? '0.00';   
    final date = order['date'] ?? '';                     
    final orderNumber = order['order_number'] ?? '#${order['id']}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFFFF6B00),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderNumber,                           // shows ORD-XXXX
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        '${items.length} items',           // real item count
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_rounded,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        date,                             
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}