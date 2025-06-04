import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = "/cart";

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.itemCount == 0
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: cartProvider.itemCount,
                        itemBuilder: (context, index) {
                          final cartItem = cartProvider.cartItems[index];
                          final discountedPrice = cartItem.product.price * (1 - cartItem.product.discount / 100);
                          return ListTile(
                            leading: Image.network(
                              cartItem.image ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              headers: const {
                                'User-Agent':
                                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print('Image load error: $error, URL: ${cartItem.image}');
                                return Image.asset(
                                  'assets/images/placeholder.jpg',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            title: Text(cartItem.product.name),
                            subtitle: Text(
                              '\$${discountedPrice.toStringAsFixed(2)} x ${cartItem.quantity}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () async {
                                try {
                                  await cartProvider.removeFromCart(cartItem.product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item removed from cart')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: cartProvider.itemCount == 0
                                ? null
                                : () async {
                                    try {
                                      await cartProvider.checkout();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Checkout successful!')),
                                      );
                                      Navigator.pushNamed(context, '/orders');
                                    } catch (e) {
                                      print('Checkout error: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Checkout error: $e')),
                                      );
                                    }
                                  },
                            child: const Text('Checkout'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}