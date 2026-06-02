import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavTap;

  const Sidebar({super.key, required this.currentIndex, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.point_of_sale_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Text('Pointsell',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          // Nav Items
          _navItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _navItem(Icons.inventory_2_outlined, 'Products', 1),
          _navItem(Icons.category_outlined, 'Categories', 2),
          _navItem(Icons.people_outline, 'Users', 3),
          _navItem(Icons.receipt_long_outlined, 'Orders', 4),
          _navItem(Icons.bar_chart_outlined, 'Reports', 5),
          const Spacer(),
          const Divider(color: Colors.white12),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: const Text('Logout', style: TextStyle(color: Colors.white54)),
            onTap: () {
             
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B00).withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isActive ? const Color(0xFFFF6B00) : Colors.white54, size: 20),
        title: Text(label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFF6B00) : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            )),
        onTap: () => onNavTap(index),
      ),
    );
  }
}
