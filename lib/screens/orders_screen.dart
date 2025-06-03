import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
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
                    return ListTile(
                      leading: Image.network(
                        item.product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/placeholder.jpg');
                        },
                      ),
                      title: Text(item.product.name),
                      subtitle: Text(
                        '\$${(item.product.price * (1 - item.product.discount / 100) * item.quantity).toStringAsFixed(2)}',
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
                id: (orders.length + 1).toString(),
                items: List<CartItem>.from(cartProvider.items),
                total: cartProvider.totalPrice,
                date: DateTime.now(),
              ));
            });
            cartProvider.clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully')),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}