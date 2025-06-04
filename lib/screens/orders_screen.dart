import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    const int currentIndex = 2; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.pink),
      ),
      body: cartProvider.orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.pink),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: cartProvider.orders.length,
              itemBuilder: (context, index) {
                final Order order = cartProvider.orders[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, color: Colors.pink, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Order #${order.id}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Date: ${order.date.toString().substring(0, 16)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total: \$${order.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Items: ${order.items.length}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        SizedBox(height: 8),
                        ...order.items.map((item) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.image ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Image load error: $error, URL: ${item.image}');
                                        return Image.network(
                                          "https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg",
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'x ${item.quantity}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${(item.product.price * (1 - item.product.discount / 100) * item.quantity).toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
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
                break; 
            }
          },
        ),
      ),
    );
  }
}