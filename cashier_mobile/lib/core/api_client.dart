import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  // ─────────────────────────────────────────
  // IN-MEMORY TOKEN CACHE
  // Reads from storage once, then reuses in RAM
  // Much faster than reading secure storage every request
  // ─────────────────────────────────────────
  static String? _cachedToken;

  // Call this after login to cache immediately
  static void setToken(String token) {
    _cachedToken = token;
  }

  // Call this after logout to clear cache
  static void clearToken() {
    _cachedToken = null;
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(

      // ─────────────────────────────────────
      // BEFORE every request
      // Use cached token first, fallback to storage
      // ─────────────────────────────────────
      onRequest: (options, handler) async {
        // Use cached token if available (fast, no I/O)
        // Otherwise read from storage and cache it
        _cachedToken ??= await _storage.read(key: 'auth_token');

        if (_cachedToken != null) {
          options.headers['Authorization'] = 'Bearer $_cachedToken';
        }

        return handler.next(options);
      },

      // ─────────────────────────────────────
      // WHEN an error happens
      // 401 = token expired → clear both cache and storage
      // ─────────────────────────────────────
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          ApiClient.clearToken(); // clear memory cache
          await _storage.delete(key: 'auth_token'); // clear storage
        }

        return handler.next(error);
      },
    ));
  }
}