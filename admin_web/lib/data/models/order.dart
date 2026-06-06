import 'order_item.dart';
import 'user.dart';

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

class Order {
  final int id;
  final int userId;
  final String orderNumber;
  final double subtotal;
  final double discount;
  final double grandTotal;
  final String paymentMethod;
  final double amountReceived;
  final double changeAmount;
  final String status;
  final User? user;
  final List<OrderItem> items;
  final int itemsCount;   // ✅ new field
  final String cashier;
  final DateTime? date;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.paymentMethod,
    required this.amountReceived,
    required this.changeAmount,
    required this.status,
    this.user,
    required this.items,
    required this.itemsCount,  
    required this.cashier,
    this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return Order(
      id:             _parseInt(json['id']),
      userId:         _parseInt(json['user_id']),
      orderNumber:    (json['order_number']  as String?) ?? '',
      subtotal:       _parseDouble(json['subtotal']),
      discount:       _parseDouble(json['discount']),
      grandTotal:     _parseDouble(json['grand_total']),
      paymentMethod:  (json['payment_method'] as String?) ?? '',
      amountReceived: _parseDouble(json['amount_received']),
      changeAmount:   _parseDouble(json['change_amount']),
      status:         (json['status'] as String?) ?? 'pending',
      user:           json['user'] != null
                        ? User.fromJson(json['user'] as Map<String, dynamic>)
                        : null,
      items:          itemsList,
      // ✅ use items_count from API, fall back to actual items length
      itemsCount:     _parseInt(json['items_count']) > 0
                        ? _parseInt(json['items_count'])
                        : itemsList.length,
      cashier:        (json['cashier'] as String?) ?? '',
      date:           json['date'] != null 
                      ? DateTime.tryParse(json['date'])  // ✅ tryParse not parse
                      : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'user_id':        userId,
    'order_number':   orderNumber,
    'subtotal':       subtotal,
    'discount':       discount,
    'grand_total':    grandTotal,
    'payment_method': paymentMethod,
    'amount_received':amountReceived,
    'change_amount':  changeAmount,
    'status':         status,
    'user':           user?.toJson(),
    'items':          items.map((e) => e.toJson()).toList(),
    'items_count':    itemsCount,
    'cashier':        cashier,
    'date':           date?.toIso8601String(),
  };
}