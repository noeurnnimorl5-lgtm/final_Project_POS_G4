import 'package:flutter/material.dart';
import 'package:admin_web/data/models/user.dart'; 

class UserTable extends StatelessWidget {
  final List<User> users;
  const UserTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08), 
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final u = users[index];
                return _buildRow(u);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 3, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text('Joined', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildRow(User u) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Name + avatar
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF6B00).withValues(alpha: 0.1), // ✅ fixed
                  child: Text(
                    u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Color(0xFFFF6B00), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Text(u.email, style: TextStyle(color: Colors.grey[600])),
          ),

          // Role (hardcoded as Cashier for now)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.1), // ✅ fixed
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Cashier',
                  style: TextStyle(color: Color(0xFFFF6B00), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),

          // Status
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: u.isActive
                    ? Colors.green.withValues(alpha: 0.1) // ✅ fixed
                    : Colors.red.withValues(alpha: 0.1),   // ✅ fixed
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                u.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: u.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Joined date (format DateTime → String)
          Expanded(
            child: Text(
              u.createdAt is DateTime
                  ? (u.createdAt as DateTime).toIso8601String().split('T').first
                  : u.createdAt.toString(),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ),

          // Actions
          SizedBox(
            width: 80,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFFFF6B00)),
              onPressed: () {
                // TODO: implement edit user dialog
              },
              tooltip: 'Edit',
            ),
          ),
        ],
      ),
    );
  }
}
