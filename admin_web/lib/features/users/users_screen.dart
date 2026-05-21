import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../data/models/user.dart';
import 'widgets/user_table.dart';
import 'widgets/add_cashier_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getUsers();
      setState(() => users = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAddCashierDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCashierDialog(onAdded: loadUsers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text('Cashiers',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showAddCashierDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Cashier',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                  : UserTable(users: users),
            ),
          ],
        ),
      ),
    );
  }
}
