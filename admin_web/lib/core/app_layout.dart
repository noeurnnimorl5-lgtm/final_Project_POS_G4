import 'package:admin_web/features/orders/orders_screen.dart';
import 'package:flutter/material.dart';
import 'sidebar.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/products/products_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/users/users_screen.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ProductsScreen(),
    CategoriesScreen(),
    UsersScreen(),
    OrdersScreen(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      drawer: isMobile
          ? Drawer(child: Sidebar(currentIndex: _currentIndex, onNavTap: _onNavTap))
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) Sidebar(currentIndex: _currentIndex, onNavTap: _onNavTap),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
