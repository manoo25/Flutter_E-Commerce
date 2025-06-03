import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cartProvider.itemCount == 0
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final cartItem = cartProvider.items[index];
                final discountedPrice = cartItem.product.price * (1 - cartItem.product.discount / 100);
                return ListTile(
                  leading: Image.network(
                    cartItem.product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/images/placeholder.jpg');
                    },
                  ),
                  title: Text(cartItem.product.name),
                  subtitle: Text(
                    '\$${discountedPrice.toStringAsFixed(2)} x ${cartItem.quantity}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () async {
                      await cartProvider.removeFromCart(cartItem.product.id);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: cartProvider.itemCount > 0
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/orders');
                      cartProvider.clearCart();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}