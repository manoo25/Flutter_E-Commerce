import 'package:flutter_application_1/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': product.id,
      'qty': quantity,
      'product': product.toJson(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['qty'] as int,
    );
  }

  String get image => product.image ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg';
}