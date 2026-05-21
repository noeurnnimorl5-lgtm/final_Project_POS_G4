import 'package:flutter/material.dart';

/// Live feed of the most recent transactions.
class RecentActivity extends StatelessWidget {
  final List transactions;
  const RecentActivity({super.key, required this.transactions});

  // Shown when the API returns an empty list
  static const _demoTransactions = [
    {
      'id': '#TXN-0041', 'cashier': 'Alice',
      'amount': 48.50, 'items': 3, 'time': '2 min ago', 'status': 'completed',
    },
    {
      'id': '#TXN-0040', 'cashier': 'Bob',
      'amount': 120.00, 'items': 7, 'time': '11 min ago', 'status': 'completed',
    },
    {
      'id': '#TXN-0039', 'cashier': 'Alice',
      'amount': 22.75, 'items': 2, 'time': '35 min ago', 'status': 'refunded',
    },
    {
      'id': '#TXN-0038', 'cashier': 'Carlos',
      'amount': 85.00, 'items': 5, 'time': '1 hr ago', 'status': 'completed',
    },
    {
      'id': '#TXN-0037', 'cashier': 'Bob',
      'amount': 33.20, 'items': 4, 'time': '2 hr ago', 'status': 'pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final txns = transactions.isEmpty
        ? _demoTransactions
        : List<Map<String, dynamic>>.from(transactions);

    return Container(
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ...txns.map((txn) => _TransactionItem(txn: txn)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Transactions',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              SizedBox(height: 2),
              Text('Latest activity',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          // Live indicator dot
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text('Live',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50))),
        ],
      ),
    );
  }
}

// ── Single transaction row ───────────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  final Map<String, dynamic> txn;
  const _TransactionItem({required this.txn});

  Color _statusColor(String status) {
    switch (status) {
      case 'refunded': return Colors.red;
      case 'pending':  return Colors.orange;
      default:         return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status      = txn['status'] ?? 'completed';
    final statusColor = _statusColor(status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Receipt icon
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_rounded,
                color: Color(0xFFFF6B00), size: 18),
          ),
          const SizedBox(width: 12),
          // ID + cashier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn['id'] ?? '',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 3),
                Text('${txn['cashier']} · ${txn['items']} items',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          // Amount + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${(txn['amount'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                  ),
                  const SizedBox(width: 6),
                  Text(txn['time'] ?? '',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey[400])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared decoration ────────────────────────────────────────────────────────

final _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.07),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ],
);