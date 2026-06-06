import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Only for web export
import 'package:admin_web/data/models/category.dart';
import 'package:admin_web/data/models/order.dart';
import 'package:admin_web/data/models/product.dart';
import 'package:admin_web/data/models/user.dart';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // -------------------------
  // Products
  // -------------------------
  static Future<List<Product>> getProducts({String? search}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/admin/products').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: await AuthService.getHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((e) => Product.fromJson(e)).toList();
    }

    final body = jsonDecode(response.body);
    throw ApiException(
      body['message'] ?? 'Failed to load products',
      statusCode: response.statusCode,
    );
  }

  static Future<Product> createProduct({
    required String name,
    required String description,
    required int categoryId, // parameter name can stay camelCase
    required double price,
    required int stock,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/products'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId.toString(); //  snake_case for Laravel
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['is_active'] = '1';

    if (imageBytes != null && imageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: imageName),
      );
    }

    final response = await http.Response.fromStream(await request.send());
    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Product.fromJson(body['data']);
    }

    throw ApiException(
      body['message'] ?? 'Failed to create product',
      statusCode: response.statusCode,
    );
  }

  static Future<Product> updateProduct({
    required int id,
    required String name,
    required String description,
    required int categoryId,
    required double price,
    required int stock,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/products/$id'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId.toString();
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['is_active'] = '1';
    request.fields['_method'] = 'PUT';

    if (imageBytes != null && imageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: imageName),
      );
    }

    final response = await http.Response.fromStream(await request.send());
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Product.fromJson(body['data']);
    }

    throw ApiException(
      body['message'] ?? 'Failed to update product',
      statusCode: response.statusCode,
    );
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/products/$id'),
      headers: await AuthService.getHeaders(),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw ApiException(
        body['message'] ?? 'Failed to delete product',
        statusCode: response.statusCode,
      );
    }
  }

  // -------------------------
  // Categories
  // -------------------------
  static Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/categories'),
      headers: await AuthService.getHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  static Future<Category> createCategory(String name, {String? color}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/categories'),
      headers: await AuthService.getHeaders(),
      body: jsonEncode({'name': name, 'color': color ?? '#FF6B00'}),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return Category.fromJson(json['data']);
    }
    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Failed to create category',
    );
  }

  static Future<Category> updateCategory(
    int id,
    String name, {
    String? color,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/categories/$id'),
      headers: await AuthService.getHeaders(),
      body: jsonEncode({'name': name, 'color': color ?? '#FF6B00'}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Category.fromJson(json['data']);
    }
    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Failed to update category',
    );
  }

  static Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/categories/$id'),
      headers: await AuthService.getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Failed to delete category',
      );
    }
  }

  // -------------------------
  // Orders
  // -------------------------
  static Future<Order> getOrderById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/orders/$id'),
      headers: await AuthService.getHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Order.fromJson(json['data']);
    }

    final body = jsonDecode(response.body);
    throw ApiException(
      body['message'] ?? 'Failed to load order',
      statusCode: response.statusCode,
    );
  }

  static Future<List<Order>> getOrders({
    int page = 1,
    String? search,
    String? status,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final uri = Uri.parse('$baseUrl/admin/orders').replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: await AuthService.getHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((e) => Order.fromJson(e)).toList();
    }

    throw ApiException(
      'Failed to load orders',
      statusCode: response.statusCode,
    );
  }

  // -------------------------
  // Users
  // -------------------------
  static Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: await AuthService.getHeaders(),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>;
      return data.map((e) => User.fromJson(e)).toList();
    }
    throw Exception('Failed to load users');
  }

  static Future<User> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: await AuthService.getHeaders(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return User.fromJson(json['data']);
    }
    throw Exception(
      jsonDecode(response.body)['message'] ?? 'Failed to create user',
    );
  }

  // -------------------------
  // Dashboard
  // -------------------------
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: await AuthService.getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load dashboard');
  }

  // -------------------------
  // Reports
  // -------------------------
 static Future<Map<String, dynamic>> getReport() async {
  final uri = Uri.parse('$baseUrl/admin/reports');
  final response = await http.get(
    uri,
    headers: await AuthService.getHeaders(),
  );
  if (response.statusCode == 200) return jsonDecode(response.body);
  throw ApiException('Failed to load report', statusCode: response.statusCode);
}

static Future<Map<String, dynamic>> getReportByDate(DateTime date) async {
  final uri = Uri.parse(
    '$baseUrl/admin/reports?date=${date.toIso8601String().split("T").first}',
  );
  final response = await http.get(
    uri,
    headers: await AuthService.getHeaders(),
  );
  if (response.statusCode == 200) return jsonDecode(response.body);
  throw ApiException('Failed to load report', statusCode: response.statusCode);
}

}