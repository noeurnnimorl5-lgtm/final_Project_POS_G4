import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final user = UserModel.fromJson(response.data);
      await _storage.write(key: 'auth_token', value: user.token);
      return user;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}