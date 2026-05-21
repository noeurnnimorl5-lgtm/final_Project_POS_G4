import 'package:flutter/material.dart';

/// Table listing best-selling products with rank, price, units sold and revenue.
class TopProductsTable extends StatelessWidget {
  final List products;
  const TopProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildColumnLabels(),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _buildRows(),
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
              Text('Top Products',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              SizedBox(height: 2),
              Text('Best sellers this week',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text('View all',
                style: TextStyle(
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnLabels() {
    labelStyle(String text) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey[400],
        letterSpacing: 0.8);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 36),
          Expanded(
            flex: 3,
            child: Text('PRODUCT',
                style: labelStyle('PRODUCT')
                    .copyWith(color: Colors.grey)),
          ),
          Expanded(
              child: Text('PRICE',
                  style: labelStyle('PRICE'), textAlign: TextAlign.right)),
          const SizedBox(width: 16),
          Expanded(
              child: Text('SOLD',
                  style: labelStyle('SOLD'), textAlign: TextAlign.right)),
          const SizedBox(width: 16),
          Expanded(
              child: Text('REVENUE',
                  style: labelStyle('REVENUE'),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildRows() {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('No products available',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final maxSold = (products.first['sold'] ?? 1) as num;

    return Column(
      children: products.asMap().entries.map((entry) {
        final i       = entry.key;
        final p       = entry.value as Map<String, dynamic>;
        final price   = double.tryParse('${p['price'] ?? 0}') ?? 0.0;
        final sold    = (p['sold'] ?? 0) as num;
        final revenue = price * sold;
        final ratio   = maxSold == 0 ? 0.0 : sold / maxSold;

        return _ProductRow(
          rank:     i + 1,
          name:     p['name'] ?? '',
          price:    price,
          sold:     sold.toInt(),
          revenue:  revenue,
          progress: ratio.toDouble(),
          isLast:   i == products.length - 1,
        );
      }).toList(),
    );
  }
}

// ── Single product row ───────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final int rank;
  final String name;
  final double price;
  final int sold;
  final double revenue;
  final double progress;
  final bool isLast;

  static const _rankColors = [
    Color(0xFFFF6B00),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
  ];

  const _ProductRow({
    required this.rank,
    required this.name,
    required this.price,
    required this.sold,
    required this.revenue,
    required this.progress,
    required this.isLast,
  });

  Color get _rankColor =>
      rank <= 3 ? _rankColors[rank - 1] : Colors.grey[300]!;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              _RankBadge(rank: rank, color: _rankColor),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: Colors.grey[100],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_rankColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('\$${price.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('$sold',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('\$${revenue.toStringAsFixed(0)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B00))),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF8F8F8)),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;
  const _RankBadge({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    final isTop = rank <= 3;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isTop
            ? color.withOpacity(0.12)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text('$rank',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isTop ? color : Colors.grey[400])),
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