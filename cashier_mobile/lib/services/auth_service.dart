import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data);

      // Cache token in RAM immediately after login
      ApiClient.setToken(user.token);

      await _storage.write(
        key: 'auth_token',
        value: user.token,
      );

      await _storage.write(
        key: 'user_data',
        value: jsonEncode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role': user.role,
        }),
      );

      return user;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Login failed',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
    } finally {
      ApiClient.clearToken(); // clear RAM cache
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final raw = await _storage.read(key: 'user_data');

      if (raw == null) return null;

      return Map<String, dynamic>.from(jsonDecode(raw));
    } catch (e) {
      print('getUser Error: $e');
      return null;
    }
  }
}