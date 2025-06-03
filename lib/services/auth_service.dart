import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://ecommerce.routemisr.com/api/v1';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final body = jsonEncode({'email': email, 'password': password});
      print('Login request body: $body');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await saveToken(token);
          return data;
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String rePassword,
    required String address,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      final body = jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'rePassword': rePassword,
        'address': address,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      });
      print('Register request body: $body');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          await saveToken(token);
          return data;
        } else {
          throw Exception('Token not found in response');
        }
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved: $token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Retrieved token: $token');
    return token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('Token cleared');
  }
}