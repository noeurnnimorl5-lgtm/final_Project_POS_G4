import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'widgets/order_card.dart';
import 'widgets/empty_order_state.dart';
import 'widgets/order_detail_sheet.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final data = await ApiService.getOrders();

      setState(() {
        orders = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshOrders,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? EmptyOrderState(onRefresh: refreshOrders)
              : RefreshIndicator(
                  onRefresh: refreshOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];

                      return OrderCard(
                        order: order,
                        onTap: () {
                          showOrderDetailSheet(context, order);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}