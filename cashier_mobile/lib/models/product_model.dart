import 'package:cashier_mobile/services/api_service.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final String priceFormatted;
  final String imageUrl;
  final double rating;
  final int stock;
  final String stockStatus;
  final String categoryName;
  final String categorySlug;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceFormatted,
    required this.imageUrl,
    required this.rating,
    required this.stock,
    required this.stockStatus,
    required this.categoryName,
    required this.categorySlug,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Try all common field names Laravel might return for the image
    final rawImage = json['image_url'] ??
        json['image'] ??
        json['image_path'] ??
        json['photo'] ??
        json['thumbnail'] ??
        '';

    print('🖼️  Raw image value: $rawImage');

    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'].toString(),
      priceFormatted: json['price_formatted'] ?? '\$${json['price']}',
      imageUrl: ApiService.fixImageUrl(rawImage.toString()),
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      stockStatus: json['stock_status'] ?? 'in_stock',
      categoryName: json['category']?['name'] ?? '',
      categorySlug: json['category']?['slug'] ?? '',
    );
  }
}