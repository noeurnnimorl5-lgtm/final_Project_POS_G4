import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'widgets/order_card.dart';
import 'widgets/empty_order_state.dart';
import 'widgets/order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool isLoading = true;
  bool _hasLoaded = false; // track if already loaded
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) loadOrders(); //  only load once
  }

  Future<void> loadOrders() async {
    //  Only show spinner on first load, not on tab switch
    if (!_hasLoaded) setState(() => isLoading = true);

    try {
      final data = await ApiService.getOrders();
      setState(() {
        orders = data;
        isLoading = false;
        _hasLoaded = true; //  mark as loaded
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Manual refresh still works — shows spinner intentionally
  Future<void> refreshOrders() async {
    setState(() => isLoading = true);
    await loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, //  no back arrow since it's a tab
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF6B00)),
            onPressed: refreshOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            )
          : orders.isEmpty
              ? EmptyOrderState(onRefresh: refreshOrders)
              : RefreshIndicator(
                  onRefresh: refreshOrders,
                  color: const Color(0xFFFF6B00),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        // onTap: () => showOrderDetailSheet(context, order),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}