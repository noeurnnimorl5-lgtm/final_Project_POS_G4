import 'package:admin_web/services/api_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../data/models/product.dart';

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductsNotifier() : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts({String search = ''}) async {
    state = const AsyncValue.loading();
    try {
      final data = await ApiService.getProducts(search: search);
      state = AsyncValue.data(data);
   } catch (e, st) {
    debugPrint('Error loading products: $e');
   state = AsyncValue.error(_extractErrorMessage(e), st);
}

  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final newProduct = await ApiService.createProduct(
        name:        productData['name'],
        description: productData['description'],
        categoryId:  productData['categoryId'],
        price:       productData['price'],
        stock:       productData['stock'],
        imageBytes:  productData['imageBytes'],
        imageName:   productData['imageName'],
      );

      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, newProduct]);
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final updated = await ApiService.updateProduct(
        id:          id,
        name:        productData['name'],
        description: productData['description'],
        categoryId:  productData['categoryId'],
        price:       productData['price'],
        stock:       productData['stock'],
        imageBytes:  productData['imageBytes'],
        imageName:   productData['imageName'],
      );

      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([
        for (final p in current)
          if (p.id == id) updated else p,
      ]);
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> deleteProduct(int id) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncValue.data(previous.where((p) => p.id != id).toList());

    try {
      await ApiService.deleteProduct(id);
    } catch (e) {
      state = AsyncValue.data(previous);
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(Object e) {
  if (e is ApiException && e.message.isNotEmpty) {
    return e.message;
  }
  return 'Something went wrong. Please try again.';
}

}

final productsNotifierProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>(
        (ref) => ProductsNotifier());
