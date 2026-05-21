import 'package:admin_web/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order.dart';

// ── Search / filter state ────────────────────────────────────────────────────

class OrderFilterState {
  final String search;
  final String? statusFilter; 
  final int page;

  const OrderFilterState({
    this.search = '',
    this.statusFilter,
    this.page = 1,
  });

  OrderFilterState copyWith({
    String? search,
    String? statusFilter,
    bool clearStatus = false,
    int? page,
  }) {
    return OrderFilterState(
      search: search ?? this.search,
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      page: page ?? this.page,
    );
  }
}

class OrderFilterNotifier extends StateNotifier<OrderFilterState> {
  OrderFilterNotifier() : super(const OrderFilterState());

  void setSearch(String query) =>
      state = state.copyWith(search: query, page: 1);

  void setStatus(String? status) =>
      state = state.copyWith(
        statusFilter: status,
        clearStatus: status == null,
        page: 1,
      );

  void setPage(int page) => state = state.copyWith(page: page);

  void reset() => state = const OrderFilterState();
}

final orderFilterProvider =
    StateNotifierProvider<OrderFilterNotifier, OrderFilterState>(
  (ref) => OrderFilterNotifier(),
);

// ── Orders list provider  ─────────────────────

final ordersProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final filter = ref.watch(orderFilterProvider);
  return ApiService.getOrders(
    page: filter.page,
    search: filter.search.isNotEmpty ? filter.search : null,
    status: filter.statusFilter, 
  );
});

// ── Single order detail provider ─────────────────────────────────────────────

final orderDetailProvider =
    FutureProvider.autoDispose.family<Order, int>((ref, id) async {
  return ApiService.getOrderById(id);
});
