import 'package:flutter/material.dart';

class PosOfflineBanner extends StatelessWidget {
  const PosOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        '⚠ Offline — showing cached products',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}