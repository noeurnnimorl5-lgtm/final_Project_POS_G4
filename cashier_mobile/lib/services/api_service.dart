import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'local_cache_service.dart';
import 'offline_queue_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1/cashier';
  static const _storage = FlutterSecureStorage();

  // ── In-memory cache ──────────────────────────
  static List<ProductModel>? _allProductsCache;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  // ── Connectivity cache — don't check network on every call ──
  static bool _cachedOnlineStatus = true;
  static DateTime? _lastConnectivityCheck;
  static const _connectivityCacheDuration = Duration(seconds: 10);

  static bool get _isCacheValid =>
      _allProductsCache != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheDuration;

  static List<ProductModel>? get cachedProducts => _allProductsCache;

  // ── Check connectivity (cached for 10s) ──────
  static Future<bool> get isOnline async {
    final now = DateTime.now();
    if (_lastConnectivityCheck != null &&
        now.difference(_lastConnectivityCheck!) < _connectivityCacheDuration) {
      return _cachedOnlineStatus;
    }

    // ✅ v7 returns List<ConnectivityResult>
    final List<ConnectivityResult> results =
    await Connectivity().checkConnectivity();

    _cachedOnlineStatus = results.isNotEmpty &&
        results.first != ConnectivityResult.none;
    _lastConnectivityCheck = now;
    return _cachedOnlineStatus;
  }

  // ── Called from main.dart when connectivity changes ──
  static void updateOnlineStatus(bool online) {
    _cachedOnlineStatus = online;
    _lastConnectivityCheck = DateTime.now();
  }

  // ── Headers ──────────────────────────────────
  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Connection': 'keep-alive',
    };
  }

  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.contains('cloudinary.com') || url.contains('res.cloudinary.com')) {
      return url;
    }
    return url.replaceAll('127.0.0.1:8000', '10.0.2.2:8000');
  }

  // ── Get Products ─────────────────────────────
  static Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
  }) async {
    if (_isCacheValid) {
      return _filterProducts(_allProductsCache!,
          search: search, category: category);
    }

    if (await isOnline) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/products'),
          headers: await _headers,
        );
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final products = (json['data'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList();
          _allProductsCache = products;
          _cacheTime = DateTime.now();
          await LocalCacheService.saveProducts(products);
          return _filterProducts(products, search: search, category: category);
        }
      } catch (_) {}
    }

    final cached = LocalCacheService.getCachedProducts();
    if (cached != null) {
      _allProductsCache = cached;
      _cacheTime = DateTime.now();
      return _filterProducts(cached, search: search, category: category);
    }
    throw Exception('No internet and no cached products available');
  }

  // ── Get Categories ───────────────────────────
  static Future<List<CategoryModel>> getCategories() async {
    if (await isOnline) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/categories'),
          headers: await _headers,
        );
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final categories = (json['data'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
          await LocalCacheService.saveCategories(categories);
          return categories;
        }
      } catch (_) {}
    }
    final cached = LocalCacheService.getCachedCategories();
    if (cached != null) return cached;
    throw Exception('No internet and no cached categories available');
  }

  // ── Create Order ─────────────────────────────
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required double discount,
    required String paymentMethod,
    required double amountReceived,
  }) async {
    if (await isOnline) {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: await _headers,
        body: jsonEncode({
          'items': items,
          'discount': discount,
          'payment_method': paymentMethod,
          'amount_received': amountReceived,
        }),
      );
      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['data'] ?? json;
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to create order');
      }
    } else {
      await OfflineQueueService.enqueue(
        items: items,
        discount: discount,
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
      );
      return {
        'offline': true,
        'message': 'Order saved offline. Will sync when connected.',
        'total': items.fold(
                0.0,
                (sum, i) =>
                    sum +
                    (i['price'] as num).toDouble() *
                        (i['quantity'] as num).toDouble()) -
            discount,
      };
    }
  }

  // ── Get Orders ───────────────────────────────
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.containsKey('data') && json['data'] is List) {
          return List<Map<String, dynamic>>.from(json['data']);
        } else if (json is List) {
          return List<Map<String, dynamic>>.from(json);
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // ── Get Single Order ─────────────────────────
  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Map<String, dynamic>.from(json['data'] ?? json);
      }
      throw Exception('Failed to load order details');
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  // ── Cancel Order ─────────────────────────────
  static Future<void> cancelOrder(String orderId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: await _headers,
      );
      if (response.statusCode != 200) {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // ── Retry Sync ───────────────────────────────
  static Future<void> retrySyncOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/retry-sync'),
        headers: await _headers,
      );
      if (response.statusCode != 200) {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to retry sync');
      }
    } catch (e) {
      throw Exception('Failed to retry sync: $e');
    }
  }

  // ── Sync Offline Orders ──────────────────────
  static Future<void> syncOfflineOrders() async {
    if (!await isOnline) return;
    final pending = await OfflineQueueService.getPendingOrders();
    for (final order in pending) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/orders'),
          headers: await _headers,
          body: jsonEncode({
            'items': jsonDecode(order['items']),
            'discount': order['discount'],
            'payment_method': order['payment_method'],
            'amount_received': order['amount_received'],
          }),
        );
        if (response.statusCode == 201) {
          await OfflineQueueService.markSynced(order['id']);
        }
      } catch (_) {}
    }
  }

  // ── Filter in memory ────────────────────────
  static List<ProductModel> _filterProducts(
    List<ProductModel> products, {
    String? search,
    String? category,
  }) {
    return products.where((p) {
      final matchSearch = search == null ||
          search.isEmpty ||
          p.name.toLowerCase().contains(search.toLowerCase());
      final matchCategory =
          category == null || category == 'all' || p.categorySlug == category;
      return matchSearch && matchCategory;
    }).toList();
  }

  static void clearProductsCache() {
    _allProductsCache = null;
    _cacheTime = null;
  }
}