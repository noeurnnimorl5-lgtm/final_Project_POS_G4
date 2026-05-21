import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class DashboardNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  DashboardNotifier() : super(const AsyncValue.loading()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.getDashboard();
      state = AsyncValue.data(response['data']);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<Map<String, dynamic>>>(
        (ref) => DashboardNotifier());
