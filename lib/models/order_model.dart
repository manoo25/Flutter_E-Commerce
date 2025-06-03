import 'package:flutter_application_1/models/cart_item_model.dart';

class Order {
  final int id;
  final List<CartItem> items;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'date': date.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}