import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  static List<Order> _orders = []; // Static list to store orders
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  List<Order> get orders => _orders; // Getter for orders

  Future<void> addToCart(Product product, int quantity) async {
    try {
      _isLoading = true;
      notifyListeners();

      final cartItem = CartItem(product: product, quantity: quantity);

      // Check if product already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingItemIndex != -1) {
        // Update quantity if product exists
        _cartItems[existingItemIndex] = CartItem(
          product: product,
          quantity: _cartItems[existingItemIndex].quantity + quantity,
        );
      } else {
        // Add new item to cart
        _cartItems.add(cartItem);
      }

      print('Cart updated: ${_cartItems.length} items');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error adding to cart: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _cartItems.removeWhere((item) => item.product.id == productId);
      print('Item removed from cart: $productId');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error removing from cart: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> checkout() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Create a new order from cart items
      final order = Order(
        id: _orders.length + 1, // Simple ID generation
        items: List.from(_cartItems),
        total: totalPrice,
        date: DateTime.now(), // Fixed: Use DateTime.now() instead of 'Today'
      );

      // Add to static orders list
      _orders.add(order);
      print('Order added: Order #${order.id}, Total: \$${order.total}');

      // Clear cart after checkout
      _cartItems.clear();
      print('Cart cleared after checkout');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Checkout error: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Checkout failed: $e');
    }
  }

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      final discountedPrice = item.product.price * (1 - item.product.discount / 100);
      return sum + (discountedPrice * item.quantity);
    });
  }

  int get itemCount => _cartItems.length;
}