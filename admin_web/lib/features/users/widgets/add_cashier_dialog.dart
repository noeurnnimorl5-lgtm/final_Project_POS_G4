import 'package:admin_web/services/api_service.dart';
import 'package:flutter/material.dart';


class AddCashierDialog extends StatelessWidget {
  final VoidCallback onAdded;
  const AddCashierDialog({super.key, required this.onAdded});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Cashier'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(nameController, 'Full Name'),
            const SizedBox(height: 12),
            _buildField(emailController, 'Email'),
            const SizedBox(height: 12),
            _buildField(passwordController, 'Password', obscure: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ApiService.createUser(
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
              );
              Navigator.pop(context);
              onAdded();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cashier created!'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
