import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product_model.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/product_details_screen.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/login': (context) => LoginScreen(),
      '/register': (context) => RegisterScreen(),
      '/home': (context) => HomeScreen(),
      '/category': (context) => CategoryScreen(),
      '/profile': (context) => ProfileScreen(),
      '/cart': (context) => CartScreen(),
      '/orders': (context) => OrdersScreen(),
      '/product-details': (context) => ProductDetailsScreen(
            product: ModalRoute.of(context)!.settings.arguments as Product,
          ),
    };
  }
}