import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl =
      'https://ib.jamalmoallart.com/api/v1'; 

  Future<bool> register({
    required String firstName,
    required String phone,
    required String email,
    required String password,
    required String address,
    required DateTime dateOfBirth,
    required String gender,
    required String profileImagePath,
  }) async {
    try {
      var uri = Uri.parse('https://ib.jamalmoallart.com/api/v2/register');
      var request = http.MultipartRequest('POST', uri);
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = profileImagePath;
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['password'] = password;

      String combinedAddress =
          '$address | DOB: ${dateOfBirth.toIso8601String()} | Gender: $gender';
      request.fields['address'] = combinedAddress;

      var response = await request.send();

      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Registration success: $respStr');
        return true;
      } else {
        print('Registration failed: ${response.statusCode}, $respStr');
        String errorMessage = 'Registration failed, please try again';
        try {
          final jsonResp = jsonDecode(respStr);
          if (jsonResp['message'] != null) {
            errorMessage = jsonResp['message'];
          } else if (jsonResp['error'] != null) {
            errorMessage = jsonResp['error'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$baseUrl/all/categories');
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
      final response = await http.get(
        Uri.parse('$baseUrl/products?category=$categoryName'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products for category: ${response.statusCode}',
        );
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
        body: jsonEncode({'email': email, 'password': password}),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString();
        final firstName = data['user']?['firstName']?.toString() ?? 'User';
        if (token != null && token.isNotEmpty) {
          return {'token': token, 'firstName': firstName};
        } else {
          throw Exception('No token found in response');
        }
      } else {
        throw Exception(
          'Failed to login: ${response.statusCode} - ${response.body}',
        );
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
      throw Exception('Failed to logout: $e');
    }
  }
}
