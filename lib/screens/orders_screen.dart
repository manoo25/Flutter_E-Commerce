import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: theme.primaryColor,
        elevation: 2,
      ),
      body: cartProvider.orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: cartProvider.orders.length,
              itemBuilder: (context, index) {
                final Order order = cartProvider.orders[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.receipt, color: theme.primaryColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Order #${order.id}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${order.date.toString().substring(0, 16)}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: \$${order.total.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Items: ${order.items.length}',
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Image load error: $error, URL: ${item.image}');
                                        return Image.network(
                                          'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Fallback image load error: $error');
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: theme.textTheme.bodyLarge,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'x ${item.quantity}',
                                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${(item.product.price * (1 - item.product.discount / 100) * item.quantity).toStringAsFixed(2)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.primaryColor,
                                    ),
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
    );
  }
}