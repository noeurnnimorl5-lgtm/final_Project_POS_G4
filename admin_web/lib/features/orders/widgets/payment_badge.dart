import 'package:flutter/material.dart';

/// Shows payment method with icon — cash / QR / card.
class PaymentBadge extends StatelessWidget {
  final String method;
  const PaymentBadge({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    final String label;

    switch (method.toLowerCase()) {
      case 'cash':
        icon  = Icons.payments_rounded;
        color = const Color(0xFF2E7D32);
        label = 'Cash';
        break;
      case 'qr':
        icon  = Icons.qr_code_rounded;
        color = const Color(0xFF1565C0);
        label = 'QR';
        break;
      case 'card':
        icon  = Icons.credit_card_rounded;
        color = const Color(0xFF6A1B9A);
        label = 'Card';
        break;
      default:
        icon  = Icons.payment_rounded;
        color = Colors.grey;
        label = method;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}