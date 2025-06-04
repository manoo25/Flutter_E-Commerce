import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() => AuthService.getUserData();

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 3; 

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.pink),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.pink),
                  const SizedBox(height: 16),
                  Text(
                    'No user data available',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user['profile_image'] != null
                        ? NetworkImage(user['profile_image'])
                        : const AssetImage("assets/images/placeholder.jpg") as ImageProvider,
                    onBackgroundImageError: (_, __) => const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user['first_name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['email'] ?? 'No Email',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  user['phone'] ?? 'No Phone',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  user['address'] ?? 'No Address',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (_, cart, __) => BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                break;
              case 1:
                Navigator.pushNamed(context, CartScreen.routeName);
                break;
              case 2:
                Navigator.pushNamed(context, OrdersScreen.routeName);
                break;
              case 3:
                break; 
            }
          },
        ),
      ),
    );
  }
}