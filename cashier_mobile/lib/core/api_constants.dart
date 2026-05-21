
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // ── Auth ──────────────────────────────────
  static const String login = '/auth/login'; 
  static const String logout = '/auth/logout'; 

  // ── Cashier ───────────────────────────────
  static const String products = '/cashier/products'; 
  static const String categories =
      '/cashier/categories'; 

  // ── Orders (coming soon) ──────────────────
  static const String orders = '/cashier/orders'; 
  
}
