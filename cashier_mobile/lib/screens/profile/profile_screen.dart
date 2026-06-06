import 'package:flutter/material.dart';
import 'package:cashier_mobile/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ✅ Single shared instance
  final _authService = AuthService();

  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => loading = true);
    final result = await _authService.getUser();
    if (!mounted) return;
    setState(() {
      user = result;
      loading = false;
    });
  }

  String _getInitial() {
    final name = user?['name']?.toString() ?? '';
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(
            color: Color(0xFFFF6B00))),
      );
    }

    //  If still null after loading, show fallback — don't block the screen
    final displayUser = user ?? {
      'name': 'Cashier',
      'email': '—',
      'role': 'cashier',
      'id': '—',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        color: const Color(0xFFFF6B00),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),

            // ── Avatar ──
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFF6B00),
                child: Text(
                  displayUser['name'].toString().isNotEmpty
                      ? displayUser['name'].toString()[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Name ──
            Center(
              child: Text(
                displayUser['name']?.toString() ?? 'Cashier',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Info tiles ──
            _InfoTile(
              icon: Icons.badge,
              label: 'Employee ID',
              value: displayUser['id']?.toString() ?? '—',
            ),
            _InfoTile(
              icon: Icons.email,
              label: 'Email',
              value: displayUser['email']?.toString() ?? '—',
            ),
            _InfoTile(
              icon: Icons.work_outline,
              label: 'Role',
              value: displayUser['role']?.toString() ?? 'Cashier',
            ),

            const SizedBox(height: 32),

            // ── Logout button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF6B00)),
        title: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87),
        ),
      ),
    );
  }
}