class Category {
  final int id;
  final String name;
  final String slug;
  final String color;
  final bool isActive;
  final int productsCount; // <-- add this field

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.color,
    required this.isActive,
    required this.productsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    slug: json['slug'] ?? 'unknown',
    color: json['color'] ?? '#FFFFFF',
    isActive: json['is_active'] ?? false,
    productsCount: json['products_count'] ?? 0,
  );
}


  // Convert Category → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'color': color,
      'is_active': isActive,
      'products_count': productsCount,
    };
  }
}
