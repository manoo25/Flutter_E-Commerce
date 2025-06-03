import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice {
    return _items.fold(0, (total, item) {
      final discountedPrice = item.product.price * (1 - item.product.discount / 100);
      return total + discountedPrice * item.quantity;
    });
  }

  int get itemCount => _items.length;

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart');
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _items = decodedData.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart', encodedData);
  }

  void addItem(String id, String name, double price, String image) {
    final existingIndex = _items.indexWhere((item) => item.product.id == id);
    if (existingIndex >= 0) {
      _items[existingIndex] = CartItem(
        product: _items[existingIndex].product,
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartItem(
        product: Product(
          id: id,
          name: name,
          price: price,
          image: image,
          discount: 0.0,
          category: 'Uncategorized',
          description: '',
        ),
        quantity: 1,
      ));
    }
    saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(String id) async {
    _items.removeWhere((item) => item.product.id == id);
    await saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items = [];
    saveCart();
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeFromCart(id);
    } else {
      final index = _items.indexWhere((item) => item.product.id == id);
      if (index >= 0) {
        _items[index] = CartItem(
          product: _items[index].product,
          quantity: quantity,
        );
        saveCart();
        notifyListeners();
      }
    }
  }
}