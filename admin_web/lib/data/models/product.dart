import 'category.dart';

class Product {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String imagePublicId;
  final double rating;
  final bool isActive;
  final String stockStatus;
  final Category category;
  final String priceFormatted;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.imagePublicId,
    required this.rating,
    required this.isActive,
    required this.stockStatus,
    required this.category,
    required this.priceFormatted,
  });
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] ?? 0,
    categoryId: json['category_id'] ?? 0,
    name: json['name'] ?? '',
    slug: json['slug'] ?? '',
    description: json['description'] ?? '',
    price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
    stock: json['stock'] ?? 0,
    imageUrl: json['image_url'] ?? '',
    imagePublicId: json['image_public_id'] ?? '',
    rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
    isActive: json['is_active'] == true || json['is_active'] == 1,
    stockStatus: json['stock_status'] ?? '',
    category: json['category'] != null
        ? Category.fromJson(json['category'])
        : Category(
            id: 0,
            name: 'Unknown',
            slug: 'unknown',         
            color: '#CCCCCC',
            isActive: false,          
            productsCount: 0,         
          ),
    priceFormatted: json['price_formatted'] ?? '',
  );
}



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'image_public_id': imagePublicId,
      'rating': rating,
      'is_active': isActive,
      'stock_status': stockStatus,
      'category': category.toJson(),
      'price_formatted': priceFormatted,
    };
  }
}
