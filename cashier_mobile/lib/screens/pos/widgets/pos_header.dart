import 'package:flutter/material.dart';

class PosHeader extends StatelessWidget {
  final int totalCartItems;
  final VoidCallback onCartTap;

  const PosHeader({
    super.key,
    required this.totalCartItems,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'POS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Cart Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                onPressed: onCartTap,
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B00),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$totalCartItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}