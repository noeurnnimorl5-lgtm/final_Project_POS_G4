// It is the messenger between Flutter and Laravel   Flutter  →  api_client.dart  →  Laravel API
// api_client.dart is the connection between your Flutter app and your Laravel backend. Without it, Flutter has no way to call your API.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {

  // ─────────────────────────────────────────
  // SINGLETON PATTERN
  // Only one ApiClient exists in the whole app
  // Every service that calls ApiClient() gets the same object
  // ─────────────────────────────────────────
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // ─────────────────────────────────────────
  // TOOLS
  // dio      → sends HTTP requests to Laravel
  // _storage → reads/writes token on phone storage
  // ─────────────────────────────────────────
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  // ─────────────────────────────────────────
  // CONSTRUCTOR
  // Runs once when app starts
  // Sets up everything needed to talk to Laravel
  // ─────────────────────────────────────────
  ApiClient._internal() {

    // BASE SETUP
    // Sets default settings for every request
    dio = Dio(BaseOptions(
      // Base URL — all requests start from here
      // 10.0.2.2 = your PC localhost from Android emulator
      baseUrl: ApiConstants.baseUrl,

      // If server takes more than 10 seconds to connect → cancel
      connectTimeout: const Duration(seconds: 10),

      // If server takes more than 10 seconds to reply → cancel
      receiveTimeout: const Duration(seconds: 10),

      // Default headers sent with every request
      headers: {
        // Tell Laravel: I expect JSON back
        'Accept': 'application/json',
        // Tell Laravel: I am sending JSON data
        'Content-Type': 'application/json',
      },
    ));

    // INTERCEPTORS
    // Code that runs automatically before/after every request
    // Like a middleware in Laravel
    dio.interceptors.add(InterceptorsWrapper(

      // ─────────────────────────────────────
      // BEFORE every request
      // Automatically attach token to header
      // So Laravel knows who is making the request
      // ─────────────────────────────────────
      onRequest: (options, handler) async {
        // Read the saved token from phone storage
        final token = await _storage.read(key: 'auth_token');

        // If token exists → add it to the request header
        if (token != null) {
          // Laravel reads this to identify the user
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Continue sending the request
        return handler.next(options);
      },

      // ─────────────────────────────────────
      // WHEN an error happens
      // If token is expired (401) → delete it
      // So user will be asked to login again
      // ─────────────────────────────────────
      onError: (DioException error, handler) async {
        // 401 = Unauthorized = token expired or invalid
        if (error.response?.statusCode == 401) {
          // Delete the expired token from phone storage
          await _storage.delete(key: 'auth_token');
          // Next time app checks isLoggedIn() → returns false
          // User will be redirected to login screen
        }

        // Continue handling the error
        return handler.next(error);
      },
    ));
  }
}