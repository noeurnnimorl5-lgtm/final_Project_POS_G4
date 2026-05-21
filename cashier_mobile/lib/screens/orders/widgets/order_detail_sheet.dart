import 'package:flutter/material.dart';

void showOrderDetailSheet(
  BuildContext context,
  Map<String, dynamic> order,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OrderDetailSheet(order: order),
  );
}

class _OrderDetailSheet extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List? ?? [];
    final status = order['status'] ?? 'pending';
    final grandTotal = order['grand_total'] ?? '0.00';     // ✅
    final subtotal = order['subtotal'] ?? '0.00';          // ✅
    final discount = order['discount'] ?? '0.00';          // ✅
    final amountReceived = order['amount_received'] ?? '0.00'; // ✅
    final changeAmount = order['change_amount'] ?? '0.00'; // ✅
    final paymentMethod = order['payment_method'] ?? '';   // ✅
    final orderNumber = order['order_number'] ?? '#${order['id']}'; // ✅
    final date = order['date'] ?? '';                       // ✅

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
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // ── Handle ──
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderNumber,                        // ✅
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,                              // ✅
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Info row ──
            Row(
              children: [
                _InfoTile(
                  icon: Icons.payment_rounded,
                  label: 'Payment',
                  value: paymentMethod.toUpperCase(),      // ✅
                  color: const Color(0xFF9C27B0),
                ),
                const SizedBox(width: 10),
                _InfoTile(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Items',
                  value: '${items.length} products',
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Items card ──
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F0F5)),
                  ...items.asMap().entries.map((e) {
                    final item = e.value as Map<String, dynamic>;
                    final isLast = e.key == items.length - 1;
                    final name  = item['product_name'] ?? '';      // ✅
                    final price = item['product_price'] ?? '0.00'; // ✅ was: price
                    final qty   = item['quantity'] ?? 0;
                    final sub   = item['subtotal'] ?? '0.00';      // ✅

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                              Text(
                                '\$$price',                // ✅
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B00)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '×$qty',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '\$$sub',                  // ✅
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          const Divider(height: 1, color: Color(0xFFF8F8F8)),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Totals card ──
            _Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: subtotal),   
                    if ((double.tryParse('$discount') ?? 0) > 0) ...[
                      const SizedBox(height: 10),
                      _TotalRow(
                        label: 'Discount',
                        value: '-\$$discount',
                        valueColor: Colors.red,
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFF0F0F5)),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$$grandTotal',                 
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ],
                    ),
                    if ((double.tryParse('$amountReceived') ?? 0) > 0) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF0F0F5)),
                      const SizedBox(height: 12),
                      _TotalRow(
                        label: 'Amount Received',
                        value: '\$$amountReceived',        
                      ),
                      const SizedBox(height: 8),
                      _TotalRow(
                        label: 'Change',
                        value: '\$$changeAmount',        
                        valueColor: const Color(0xFF2E7D32),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _TotalRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}