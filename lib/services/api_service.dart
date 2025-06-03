import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://ib.jamalmoallart.com/api';
  static const String imageBaseUrl = 'https://ib.jamalmoallart.com';

  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // List of possible endpoints to try
      final endpoints = [
        '$baseUrl/products',
        '$baseUrl/api/products',
        '$baseUrl/items',
        '$baseUrl/shop/products',
        '$baseUrl/v1/products',
      ];

      for (var endpoint in endpoints) {
        final url = Uri.parse(endpoint);
        print('Trying Products Endpoint: $url');
        print('Get Products API Request Headers: $headers');

        final response = await http.get(url, headers: headers);

        print('Get Products API Response Status: ${response.statusCode}');
        print('Get Products API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> productsData = data is List ? data : data['data'] ?? [];
          print('Parsed Products Data: $productsData');
          return productsData.map((item) => Product.fromJson(item)).toList();
        }
      }

      throw Exception('Failed to load products: No valid endpoint found');
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // Try category endpoint
      final url = Uri.parse('$baseUrl/products?category[in]=$category');
      print('Get Products by Category API Request URL: $url');
      print('Get Products by Category API Request Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Get Products by Category API Response Status: ${response.statusCode}');
      print('Get Products by Category API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productsData = data is List ? data : data['data'] ?? [];
        print('Parsed Products by Category Data: $productsData');
        return productsData.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('Retrieved token for profile: $token');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please log in.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      print('Profile request headers: ${response.request?.headers}');
      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      print('Token cleared');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }
}