import 'package:flutter/material.dart';

/// Reusable status pill used in both list and detail views.
class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool large;

  const OrderStatusBadge({super.key, required this.status, this.large = false});

  static _StatusStyle _styleFor(String status) {
    switch (status.toLowerCase()) {
      case 'synced':
      case 'completed':
        return _StatusStyle(
          bg: const Color(0xFFE8F5E9),
          fg: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
          label: 'Completed',
        );
      case 'pending':
        return _StatusStyle(
          bg: const Color(0xFFFFF8E1),
          fg: const Color(0xFFF57F17),
          icon: Icons.schedule_rounded,
          label: 'Pending',
        );
      case 'refunded':
        return _StatusStyle(
          bg: const Color(0xFFFFEBEE),
          fg: const Color(0xFFC62828),
          icon: Icons.replay_rounded,
          label: 'Refunded',
        );
      case 'cancelled':
        return _StatusStyle(
          bg: const Color(0xFFF5F5F5),
          fg: const Color(0xFF757575),
          icon: Icons.cancel_rounded,
          label: 'Cancelled',
        );
      default:
        return _StatusStyle(
          bg: const Color(0xFFF5F5F5),
          fg: const Color(0xFF757575),
          icon: Icons.help_outline_rounded,
          label: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _styleFor(status);
    final fontSize = large ? 12.0 : 10.0;
    final iconSize = large ? 14.0 : 11.0;
    final hPad    = large ? 10.0 : 7.0;
    final vPad    = large ? 5.0  : 3.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: iconSize, color: s.fg),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: s.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;
  const _StatusStyle(
      {required this.bg,
      required this.fg,
      required this.icon,
      required this.label});
}