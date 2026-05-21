import 'package:flutter/material.dart';

/// Top bar with title, date, Export and Refresh buttons.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    final dayStr  = days[now.weekday % 7];

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$dayStr, $dateStr',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        _HeaderButton(
          icon: Icons.file_download_outlined,
          label: 'Export',
          onTap: () {},
        ),
        const SizedBox(width: 10),
        _HeaderButton(
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          onTap: () {},
          filled: true,
        ),
      ],
    );
  }
}

// ── Private sub-widget ───────────────────────────────────────────────────────

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? const Color(0xFFFF6B00) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: filled ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: filled ? Colors.white : Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}