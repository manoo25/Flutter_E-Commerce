import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://ib.jamalmoallart.com/api/v1'; // Replace with actual API base URL

 Future<List<Category>> getCategories() async {
  final url = Uri.parse('https://ib.jamalmoallart.com/api/v1/all/categories');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Category(name: json.toString())).toList();
  } else {
    throw Exception('Failed to load categories: ${response.statusCode}');
  }
}


  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryName) async {
    try {
      // Assuming API endpoint like /products?category=categoryName
      final response = await http.get(Uri.parse('$baseUrl/products?category=$categoryName'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products for category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products by category: $e');
      throw Exception('Failed to load products by category: $e');
    }
  }

Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signin'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Login API Request URL: ${Uri.parse('$baseUrl/auth/signin')}');
    print('Login API Request Body: {"email": "$email", "password": "****"}');
    print('Login API Response Status: ${response.statusCode}');
    print('Login API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']?.toString();
      final firstName = data['user']?['firstName']?.toString() ?? 'User';
      if (token != null && token.isNotEmpty) {
        return {
          'token': token,
          'firstName': firstName,
        };
      } else {
        throw Exception('No token found in response');
      }
    } else {
      throw Exception('Failed to login: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error logging in: $e');
    throw Exception('Failed to login: $e');
  }
}

  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.statusCode}');
      }
    } catch (e) {
      print('Error logging out: $e');
      throw Exception('Failed to logout: $e');
    }
  }

}