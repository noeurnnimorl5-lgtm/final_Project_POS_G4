import 'package:admin_web/data/models/product.dart';
import 'package:admin_web/features/products/edit_product_dialog.dart';
import 'package:admin_web/features/products/add_product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/products_notifier.dart';


class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  static const Color primaryColor    = Color(0xFFFF6B00);
  static const Color backgroundColor = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsNotifierProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, productsAsync),
            const SizedBox(height: 28),
            Expanded(
              child: productsAsync.when(
                data: (products) =>
                    products.isEmpty ? _buildEmptyState(context, ref) : _buildProductTable(context, products, ref),
                loading: () => const Center(child: CircularProgressIndicator(color: primaryColor)),
                error: (err, _) => Center(child: Text('Error loading products: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AsyncValue<List<Product>> productsAsync) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Products', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            productsAsync.when(
              data: (products) => Text('${products.length} products',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              loading: () => const Text('Loading...'),
              error: (err, _) => Text('Error: $err'),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => showAddProductDialog(context, ref),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Product', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => showAddProductDialog(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Add First Product', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(BuildContext context, List<Product> products, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductRow(context, ref, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: const Row(
        children: [
          SizedBox(width: 60, child: Text('IMAGE', style: headerStyle)),
          Expanded(flex: 3, child: Text('PRODUCT', style: headerStyle)),
          Expanded(child: Text('CATEGORY', style: headerStyle)),
          Expanded(child: Text('PRICE', style: headerStyle)),
          Expanded(child: Text('STOCK', style: headerStyle)),
          Expanded(child: Text('STATUS', style: headerStyle)),
          SizedBox(width: 110, child: Text('ACTIONS', style: headerStyle)),
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, WidgetRef ref, Product product) {
    final isOutOfStock = product.stockStatus == 'out_of_stock';
    final isLowStock   = product.stockStatus == 'low_stock';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.imageUrl,
              width: 52, height: 52, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52, height: 52,
                color: Colors.grey[100],
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Name + Description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                if (product.description.isNotEmpty)
                  Text(product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),

          // Category
          Expanded(
            child: Text(product.category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
          ),

          // Price
          Expanded(
            child: Text(product.priceFormatted,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
          ),

          // Stock
          Expanded(
            child: Text('${product.stock}',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOutOfStock ? Colors.red : isLowStock ? Colors.orange : Colors.black87)),
          ),

          // Status
          Expanded(
            child: Text(
              isOutOfStock ? 'Out of Stock' : isLowStock ? 'Low Stock' : 'In Stock',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isOutOfStock ? Colors.red : isLowStock ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: primaryColor),
                  onPressed: () => showEditProductDialog(context, ref, product),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref.read(productsNotifierProvider.notifier).deleteProduct(product.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
