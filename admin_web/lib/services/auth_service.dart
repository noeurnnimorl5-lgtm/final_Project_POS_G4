import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const _storage = FlutterSecureStorage();

  /// Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'admin_token');
  }

  /// Save token
  static Future<void> _saveToken(String token) async {
    await _storage.write(key: 'admin_token', value: token);
  }

  /// Remove token
  static Future<void> logout() async {
    await _storage.delete(key: 'admin_token');
  }

  /// Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Login
  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json['token'] ?? json['access_token'];
      if (token == null) throw Exception('No token returned');
      await _saveToken(token);
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? json['errors']?.toString() ?? 'Login failed');
    }
  }

  /// Get headers with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found. Please login first.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }
}
