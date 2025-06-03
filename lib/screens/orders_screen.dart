import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    // Simulate loading orders (replace with actual storage if needed)
    setState(() {
      // orders = ... (load from SharedPreferences or API if implemented)
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ExpansionTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
                  children: order.items.map((item) {
                    final discountedPrice = item.product.price * (1 - item.product.discount / 100);
                    return ListTile(
                      leading: Image.network(
                        item.product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Image load error for ${item.product.image}: $error');
                          return Image.asset('assets/images/placeholder.jpg');
                        },
                      ),
                      title: Text(item.product.name),
                      subtitle: Text(
                        '\$${(discountedPrice * item.quantity).toStringAsFixed(2)} (Qty: ${item.quantity})',
                      ),
                    );
                  }).toList(),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (cartProvider.itemCount > 0) {
            setState(() {
              orders.add(Order(
                id: DateTime.now().millisecondsSinceEpoch,
                items: List<CartItem>.from(cartProvider.items),
                total: cartProvider.totalPrice,
                date: DateTime.now(),
              ));
            });
            cartProvider.clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cart is empty')),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}