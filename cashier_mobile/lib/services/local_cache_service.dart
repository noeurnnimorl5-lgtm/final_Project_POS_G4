// lib/services/local_cache_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';


class LocalCacheService {
  static const _productsBox = 'products';
  static const _categoriesBox = 'categories';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_productsBox);
    await Hive.openBox(_categoriesBox);
  }

  // ── Save products to local cache ──
  static Future<void> saveProducts(List<ProductModel> products) async {
    final box = Hive.box(_productsBox);
    final data = products.map((p) => p.toJson()).toList();
    await box.put('all', data);
    await box.put('cached_at', DateTime.now().toIso8601String());
  }

  // ── Read products from local cache ──
  static List<ProductModel>? getCachedProducts() {
    try {
      final box = Hive.box(_productsBox);
      final data = box.get('all');
      if (data == null) return null;
      return (data as List)
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('❌ getCachedProducts error: $e');
      return null; //  return null instead of crashing
    }
  }

  // ── Save categories ──
  static Future<void> saveCategories(List<CategoryModel> categories) async {
    final box = Hive.box(_categoriesBox);
    await box.put('all', categories.map((c) => c.toJson()).toList());
  }

  static List<CategoryModel>? getCachedCategories() {
    try {
      final box = Hive.box(_categoriesBox);
      final data = box.get('all');
      if (data == null) return null;
      return (data as List)
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      print('❌ getCachedCategories error: $e');
      return null;
    }
  }
}