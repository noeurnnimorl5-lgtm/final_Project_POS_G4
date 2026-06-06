import 'package:admin_web/data/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order.dart';

import 'order_status_badge.dart';


class OrderDetailScreen extends ConsumerWidget {
  final int orderId;
  final VoidCallback? onBack; // ← add this

  const OrderDetailScreen({super.key, required this.orderId, this.onBack});

  static void push(BuildContext context, int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: orderId),
      ),
    );
  }

@override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(orderId));

    // Get order number from loaded data
    final title = detailAsync.valueOrNull?.orderNumber ?? 'Order #$orderId';


    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => onBack != null ? onBack!() : Navigator.pop(context),
        ),
        title: Text(
          title, //  shows ORD-20240605-001 once loaded
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('$err', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) => _DetailContent(order: order),
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  final Order order;

  const _DetailContent({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildInfoCards(),
          const SizedBox(height: 20),
          _buildItemsCard(),
          const SizedBox(height: 20),
          _buildTotalsCard(),
        ],
      ),
    );
  }

  // Widget _buildHandle() {
  //   return Center(
  //     child: Container(
  //       margin: const EdgeInsets.symmetric(vertical: 12),
  //       width: 40,
  //       height: 4,
  //       decoration: BoxDecoration(
  //         color: Colors.grey[300],
  //         borderRadius: BorderRadius.circular(2),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(order.date),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        OrderStatusBadge(status: order.status, large: true),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.person_rounded,
            label: 'Cashier',
           value: order.user?.name ?? (order.cashier.isNotEmpty ? order.cashier : 'Unknown'),
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.shopping_bag_rounded,
            label: 'Items',
            value: '${order.items.length} products',
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoTile(
            icon: Icons.payment_rounded,
            label: 'Payment',
            value: order.paymentMethod.toUpperCase(),
            color: const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Order Items',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  flex: 4,
                  child: Text('PRODUCT', style: _colHeaderStyle),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'PRICE',
                    style: _colHeaderStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'QTY',
                    style: _colHeaderStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'SUBTOTAL',
                    style: _colHeaderStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          ...order.items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == order.items.length - 1;
            return _ItemRow(item: item, isLast: isLast);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTotalsCard() {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _TotalRow(label: 'Subtotal', value: order.subtotal),
            if (order.discount > 0) ...[
              const SizedBox(height: 10),
              _TotalRow(
                label: 'Discount',
                value: -order.discount,
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
                  '\$${order.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF6B00),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            if (order.amountReceived > 0) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF0F0F5)),
              const SizedBox(height: 12),
              _TotalRow(label: 'Amount Received', value: order.amountReceived),
              const SizedBox(height: 8),
              _TotalRow(
                label: 'Change',
                value: order.changeAmount,
                valueColor: const Color(0xFF2E7D32),
              ),
            ],
          ],
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}  $h:$min';
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

const _colHeaderStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: Colors.grey,
  letterSpacing: 0.8,
);

class _ItemRow extends StatelessWidget {
  final dynamic item; // OrderItem
  final bool isLast;
  const _ItemRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Product name + image placeholder
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: item.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.fastfood_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.fastfood_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Expanded(
                flex: 2,
                child: Text(
                  '\$${item.productPrice.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 12),
              // Quantity badge
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '×${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Subtotal
              Expanded(
                flex: 2,
                child: Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF8F8F8)),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;
  const _TotalRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    final display = isNegative
        ? '-\$${(-value).toStringAsFixed(2)}'
        : '\$${value.toStringAsFixed(2)}';

    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const Spacer(),
        Text(
          display,
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
    return Container(
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
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
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
