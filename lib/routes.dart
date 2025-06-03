import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'models/product_model.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    try {
      return {
        '/login': (context) {
          print('Navigating to /login');
          return LoginScreen();
        },
        '/home': (context) {
          print('Navigating to /home');
          return HomeScreen();
        },
        '/category': (context) {
          print('Navigating to /category');
          return CategoryScreen();
        },
        '/product-details': (context) {
          print('Navigating to /product-details');
          final product = ModalRoute.of(context)!.settings.arguments as Product?;
          if (product == null) {
            print('Error: No product provided for /product-details');
            return HomeScreen(); // Fallback
          }
          return ProductDetailsScreen(product: product);
        },
        '/cart': (context) {
          print('Navigating to /cart');
          return CartScreen();
        },
        '/orders': (context) {
          print('Navigating to /orders');
          return OrdersScreen();
        },
        '/profile': (context) {
          print('Navigating to /profile');
          return ProfileScreen();
        },
        '/register': (context) {
          print('Navigating to /register');
          return RegisterScreen();
        },
      };
    } catch (e) {
      print('Error in Routes.getRoutes: $e');
      return {};
    }
  }
}