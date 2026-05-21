import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import 'widgets/pos_header.dart';
import 'widgets/pos_offline_banner.dart';
import 'widgets/pos_search_bar.dart';
import 'widgets/pos_category_pills.dart';
import 'widgets/pos_product_card.dart';
import 'widgets/pos_cart_button.dart';
import 'widgets/pos_empty_state.dart';
import 'widgets/pos_bottom_nav.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  String selectedCategory = 'all';
  bool isLoading = true;
  bool isOffline = false;
  Map<int, int> cartItems = {};

  // ── Lifecycle ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () => loadData());
  }

  // ── Data ──────────────────────────────────────────────
  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final cats = await ApiService.getCategories();
      final prods = await ApiService.getProducts(category: selectedCategory);
      setState(() {
        categories = cats;
        products = prods;
        isOffline = false;
      });
      for (final product in prods) {
        if (product.imageUrl.isNotEmpty) {
          precacheImage(CachedNetworkImageProvider(product.imageUrl), context);
        }
      }
    } catch (e) {
      setState(() => isOffline = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> onSearch(String value) async {
    setState(() => isLoading = true);
    try {
      final prods = await ApiService.getProducts(
        search: value,
        category: selectedCategory,
      );
      setState(() => products = prods);
    } catch (e) {
      setState(() => isOffline = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onCategoryTap(String slug) {
    setState(() => selectedCategory = slug);
    loadData();
  }

  // ── Cart Helpers ──────────────────────────────────────
  int get totalCartItems => cartItems.values.fold(0, (sum, qty) => sum + qty);

  double get totalCartPrice {
    double total = 0;
    cartItems.forEach((id, qty) {
      final product = products.firstWhere(
        (p) => p.id == id,
        orElse: () => products.first,
      );
      total += double.parse(product.price) * qty;
    });
    return total;
  }

  void addToCart(int productId) {
    setState(() => cartItems[productId] = 1);
  }

  void removeFromCart(int productId) {
    setState(() {
      final qty = cartItems[productId] ?? 0;
      if (qty <= 1) {
        cartItems.remove(productId);
      } else {
        cartItems[productId] = qty - 1;
      }
    });
  }

  void incrementCart(int productId) {
    setState(() => cartItems[productId] = (cartItems[productId] ?? 0) + 1);
  }

  // ── Navigation ────────────────────────────────────────
  Future<void> _openCart() async {
    final updatedCart = await Navigator.push<Map<int, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(cartItems: cartItems, products: products),
      ),
    );
    if (updatedCart != null) {
      setState(() => cartItems = updatedCart);
    }
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 1:
        _openCart();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        );
        break;
    }
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            PosHeader(
              totalCartItems: totalCartItems,
              onCartTap: _openCart,
            ),
            if (isOffline) const PosOfflineBanner(),
            PosSearchBar(onChanged: onSearch),
            PosCategoryPills(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategoryTap: onCategoryTap,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B00),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadData,
                      color: const Color(0xFFFF6B00),
                      child: products.isEmpty
                          ? const PosEmptyState()
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.62,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return PosProductCard(
                                  product: product,
                                  quantity: cartItems[product.id] ?? 0,
                                  onAdd: () => addToCart(product.id),
                                  onRemove: () => removeFromCart(product.id),
                                  onIncrement: () => incrementCart(product.id),
                                );
                              },
                            ),
                    ),
            ),
            if (totalCartItems > 0)
              PosCartButton(
                totalItems: totalCartItems,
                totalPrice: totalCartPrice,
                onTap: _openCart,
              ),
          ],
        ),
      ),
      bottomNavigationBar: PosBottomNav(
        currentIndex: 0,
        onTap: _onBottomNavTap,
      ),
    );
  }
}