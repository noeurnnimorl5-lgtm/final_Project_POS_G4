import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import 'app_layout.dart';

class AppRouter {
  static const String login = '/login';
  static const String app = '/app';
  static const String dashboard = '/app'; 

  static Map<String, WidgetBuilder> get routes {
    return {
      '/': (context) => const LoginScreen(),
      login: (context) => const LoginScreen(),
      app: (context) => const AppLayout(),
    };
  }
}