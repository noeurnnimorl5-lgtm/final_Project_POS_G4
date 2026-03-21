import 'package:cashier_mobile/screens/pos/pos_screen.dart';
import 'package:cashier_mobile/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'screens/Auth/login_screen.dart';

void main() {
  runApp(const MyApp());
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
    );
  }
}