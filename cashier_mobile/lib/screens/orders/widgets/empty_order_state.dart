import 'package:flutter/material.dart';

class EmptyOrderState extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyOrderState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),

          const SizedBox(height: 16),

          const Text(
            'No Orders Yet',
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}