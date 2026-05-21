int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double subtotal;
  final String? image;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id:           _parseInt(json['id']),
      orderId:      _parseInt(json['order_id']),
      productId:    _parseInt(json['product_id']),
      productName:  (json['product_name'] as String?) ?? '',       // ✅ null-safe
      productPrice: _parseDouble(json['product_price']),
      quantity:     _parseInt(json['quantity']),
      subtotal:     _parseDouble(json['subtotal']),
      image:        json['image'] as String?,                      // ✅ already nullable
    );
  }

  Map<String, dynamic> toJson() => {
    'id':            id,
    'order_id':      orderId,
    'product_id':    productId,
    'product_name':  productName,
    'product_price': productPrice,
    'quantity':      quantity,
    'subtotal':      subtotal,
    'image':         image,
  };
}