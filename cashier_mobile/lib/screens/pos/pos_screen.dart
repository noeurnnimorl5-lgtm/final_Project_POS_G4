import 'package:cashier_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';
import '../checkout/checkout_screen.dart';
import '../orders/order_history_screen.dart';
import '../profile/profile_screen.dart';
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
  int _currentNavIndex = 0;

  // Cart discount state (lifted from CartScreen)
  String _discountType = 'percent';
  double _discountValue = 0;
  final _discountController = TextEditingController();

  // ── Lifecycle ─────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () => loadData());
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
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

  double get cartSubtotal {
    double total = 0;
    cartItems.forEach((id, qty) {
      final product = products.firstWhere((p) => p.id == id);
      total += double.parse(product.price) * qty;
    });
    return total;
  }

  double get discountAmount {
    if (_discountType == 'percent') {
      return cartSubtotal * (_discountValue / 100);
    }
    return _discountValue;
  }

  double get grandTotal => cartSubtotal - discountAmount;

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

  void _updateCartQty(int id, int qty) {
    setState(() {
      if (qty <= 0) {
        cartItems.remove(id);
      } else {
        cartItems[id] = qty;
      }
    });
  }

  void _removeCartItem(int id) {
    setState(() => cartItems.remove(id));
  }

  // ── Navigation ────────────────────────────────────────
  void _onBottomNavTap(int index) {
    setState(() => _currentNavIndex = index);
  }

  // ── POS Body ──────────────────────────────────────────
  Widget _buildPosBody() {
  return SafeArea(
    child: Column(
      children: [
        PosHeader(
          totalCartItems: totalCartItems,
          onCartTap: () => setState(() => _currentNavIndex = 1),
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
              totalPrice: grandTotal,
              onTap: () => setState(() => _currentNavIndex = 1),
            ),
        ],
      ),
    );
  }

  // ── Cart Body ─────────────────────────────────────────
  Widget _buildCartBody() {
    final cartProductIds = cartItems.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // no back arrow — it's a tab
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => cartItems.clear()),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProductIds.length,
                    itemBuilder: (context, index) {
                      final id = cartProductIds[index];
                      final product =
                          products.firstWhere((p) => p.id == id);
                      final qty = cartItems[id]!;
                      return _buildCartItem(product, qty);
                    },
                  ),
                ),
                _buildSummarySection(),
              ],
            ),
    );
  }

  Widget _buildCartItem(ProductModel product, int qty) {
    return Dismissible(
      key: Key(product.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeCartItem(product.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 65,
                  height: 65,
                  color: Colors.grey[100],
                  child: Icon(Icons.fastfood, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceFormatted,
                    style: const TextStyle(
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtotal: \$${(double.parse(product.price) * qty).toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _stepperBtn(Icons.remove,
                    () => _updateCartQty(product.id, qty - 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '$qty',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _stepperBtn(
                    Icons.add, () => _updateCartQty(product.id, qty + 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Discount row
          Row(
            children: [
              const Text(
                'Discount:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              _discountTypeBtn('%', 'percent'),
              const SizedBox(width: 8),
              _discountTypeBtn('\$', 'fixed'),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText:
                        _discountType == 'percent' ? 'e.g. 10' : 'e.g. 5.00',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _discountValue = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          _priceRow('Subtotal', '\$${cartSubtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _priceRow(
            'Discount',
            '-\$${discountAmount.toStringAsFixed(2)}',
            isRed: true,
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 6),
          _priceRow(
            'Grand Total',
            '\$${grandTotal.toStringAsFixed(2)}',
            isBold: true,
            isOrange: true,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            cartItems: cartItems,
                            products: products,
                            discount: discountAmount,
                            grandTotal: grandTotal,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Checkout →',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountTypeBtn(String label, String type) {
    final isSelected = _discountType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _discountType = type;
        _discountValue = 0;
        _discountController.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool isRed = false,
    bool isBold = false,
    bool isOrange = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isRed
                ? Colors.red
                : isOrange
                    ? const Color(0xFFFF6B00)
                    : Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products from the menu',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _currentNavIndex = 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Products',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildPosBody(),            // index 0 — Home
          _buildCartBody(),           // index 1 — Cart ✅
          const OrderHistoryScreen(), // index 2 — Orders
          const ProfileScreen(),      // index 3 — Profile
        ],
      ),
      bottomNavigationBar: PosBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}