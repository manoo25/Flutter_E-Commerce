import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/category_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    '/home': (context) => HomeScreen(),
    CartScreen.routeName: (context) => CartScreen(),
    OrdersScreen.routeName: (context) => OrdersScreen(),
    ProductDetailsScreen.route: (context) => ProductDetailsScreen(),
    CategoryScreen.routeName: (context) => CategoryScreen(),
    '/register': (context) => RegisterScreen(),
    '/profile': (context) => ProfileScreen(),
  };
}