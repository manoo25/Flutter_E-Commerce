import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final apiService = ApiService();
      final fetchedUser = await apiService.getProfile();
      setState(() {
        userData = fetchedUser['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      print('Error fetching profile: $e');
    }
  }

  Future<void> _logout() async {
    try {
      final authService = AuthService();
      await authService.clearToken();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : userData == null
                  ? const Center(child: Text('No profile data found'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${userData!['name'] ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${userData!['email'] ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
    );
  }
}