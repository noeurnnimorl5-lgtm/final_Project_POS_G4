import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../../services/api_service.dart';

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  CategoriesNotifier() : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await ApiService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createCategory(String name, {String? color}) async {
    try {
      final newCategory = await ApiService.createCategory(name, color: color);
      final current = state.value ?? [];
      state = AsyncValue.data([...current, newCategory]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCategory(int id, String name, {String? color}) async {
    try {
      final updated = await ApiService.updateCategory(id, name, color: color);
      final current = state.value ?? [];
      state = AsyncValue.data([
        for (final c in current) if (c.id == id) updated else c,
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await ApiService.deleteCategory(id);
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((c) => c.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoriesNotifierProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>(
        (ref) => CategoriesNotifier());
