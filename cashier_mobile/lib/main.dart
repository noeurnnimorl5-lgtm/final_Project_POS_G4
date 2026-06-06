import 'package:cashier_mobile/screens/pos/pos_screen.dart';
import 'package:cashier_mobile/screens/splash/splash_screen.dart';
import 'package:cashier_mobile/screens/checkout/checkout_screen.dart';
import 'package:cashier_mobile/screens/receipt/receipt_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'screens/Auth/login_screen.dart';
import 'models/product_model.dart';

import 'services/local_cache_service.dart';   // ← ADD
import 'services/offline_queue_service.dart'; // ← ADD
import 'services/api_service.dart';           // ← ADD

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LocalCacheService.init();
    print('✅ LocalCacheService OK');
  } catch (e) {
    print('❌ LocalCacheService FAILED: $e');
  }

  try {
    await OfflineQueueService.init();
    print('✅ OfflineQueueService OK');
  } catch (e) {
    print('❌ OfflineQueueService FAILED: $e');
  }

  // ✅ v7 fix — results is List<ConnectivityResult>
  try {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final online = results.isNotEmpty &&
          results.first != ConnectivityResult.none;
      ApiService.updateOnlineStatus(online);
      if (online) ApiService.syncOfflineOrders();
    });
    print('✅ Connectivity listener OK');
  } catch (e) {
    print('❌ Connectivity listener FAILED: $e');
  }

  print('✅ Starting app...');
  runApp(const MyApp());
  print('✅ runApp called');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashier POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFF5821E),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/pos': (context) => const PosScreen(),
      },
      // ── Dynamic routes (need arguments) ──
      onGenerateRoute: (settings) {
        // ── Checkout Screen ───────────────
        if (settings.name == '/checkout') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CheckoutScreen(
              cartItems: args['cartItems'] as Map<int, int>,
              products: args['products'] as List<ProductModel>,
              discount: args['discount'] as double,
              grandTotal: args['grandTotal'] as double,
            ),
          );
        }

        // ── Receipt Screen ────────────────
        if (settings.name == '/receipt') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              cartItems: args['cartItems'] as Map<int, int>,
              products: args['products'] as List<ProductModel>,
              discount: args['discount'] as double,
              grandTotal: args['grandTotal'] as double,
              paymentMethod: args['paymentMethod'] as String,
              amountReceived: args['amountReceived'] as double,
              change: args['change'] as double,
            ),
          );
        }

        return null;
      },
    );
  }
}
