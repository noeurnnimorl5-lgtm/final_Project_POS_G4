import 'package:admin_web/data/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/order_card.dart';
import 'widgets/order_detail_sheet.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  int? _selectedOrderId; // ← ADD THIS

  static const _statusTabs = [
    _Tab(label: 'All',       value: null),
    _Tab(label: 'Completed', value: 'synced'),
    _Tab(label: 'Pending',   value: 'pending'),
    _Tab(label: 'Refunded',  value: 'refunded'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter      = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final notifier    = ref.read(orderFilterProvider.notifier);

    // ✅ Show detail panel instead of list when order is selected
    if (_selectedOrderId != null) {
      return OrderDetailScreen(
        orderId: _selectedOrderId!,
        onBack: () => setState(() => _selectedOrderId = null),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(filter, notifier),
          _buildStatusTabs(filter, notifier),
          _buildTableHeader(),

          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
              ),
              error: (err, _) => _ErrorView(
                message: '$err',
                onRetry: () => ref.invalidate(ordersProvider),
              ),
              data: (orders) {
                if (orders.isEmpty) return const _EmptyView();
                return RefreshIndicator(
                  color: const Color(0xFFFF6B00),
                  onRefresh: () async {
                    ref.invalidate(ordersProvider);
                    // Wait for the provider to rebuild
                    await ref.read(ordersProvider.future);
                  },                  
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) => OrderCard(
                      order: orders[i],
                      // ✅ Set selected ID instead of Navigator.push
                      onTap: () => setState(
                        () => _selectedOrderId = orders[i].id,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          _buildPagination(filter, notifier),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(OrderFilterState filter, OrderFilterNotifier notifier) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Orders',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'All transactions from your cashiers',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),

          SizedBox(
            width: 280,
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => notifier.setSearch(v),
              decoration: InputDecoration(
                hintText: 'Search order / cashier…',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: Colors.grey[400]),
                suffixIcon: filter.search.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 16, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF4F6FA),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          _ActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            filled: true,
            onTap: () {
              ref.invalidate(ordersProvider);      // ✅ invalidate
              ref.invalidate(orderFilterProvider); // ✅ also reset filter cache
            },
          ),
        ],
      ),
    );
  }

  // ── Status tabs ───────────────────────────────────────────────────────────
  Widget _buildStatusTabs(OrderFilterState filter, OrderFilterNotifier notifier) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
      child: Row(
        children: _statusTabs.map((tab) {
          final isActive = filter.statusFilter == tab.value;
          return GestureDetector(
            onTap: () => notifier.setStatus(tab.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive
                        ? const Color(0xFFFF6B00)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? const Color(0xFFFF6B00)
                      : Colors.grey[500],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Table header ──────────────────────────────────────────────────────────
  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: const [
          _ColHeader(label: 'ORDER', flex: 3),
          _ColHeader(label: 'DATE', flex: 2),
          _ColHeader(label: 'ITEMS', flex: 1),
          _ColHeader(label: 'PAYMENT', flex: 2),
          _ColHeader(label: 'TOTAL', flex: 2, rightAlign: true),
          _ColHeader(label: 'STATUS', flex: 2, rightAlign: true),
          SizedBox(width: 26),
        ],
      ),
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  Widget _buildPagination(OrderFilterState filter, OrderFilterNotifier notifier) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Page ${filter.page}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          _PageButton(
            icon: Icons.chevron_left_rounded,
            enabled: filter.page > 1,
            onTap: () => notifier.setPage(filter.page - 1),
          ),
          const SizedBox(width: 8),
          _PageButton(
            icon: Icons.chevron_right_rounded,
            enabled: true,
            onTap: () => notifier.setPage(filter.page + 1),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _Tab {
  final String label;
  final String? value;
  const _Tab({required this.label, required this.value});
}

class _ColHeader extends StatelessWidget {
  final String label;
  final int flex;
  final bool rightAlign;
  const _ColHeader({required this.label, required this.flex, this.rightAlign = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: rightAlign ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
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
              Icon(
                icon,
                size: 16,
                color: filled ? Colors.white : Colors.grey[700],
              ),
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

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : const Color(0xFFF4F6FA),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.grey[700] : Colors.grey[300],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
