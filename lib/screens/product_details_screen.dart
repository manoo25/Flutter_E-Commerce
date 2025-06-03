import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-details';
  final Product product;

  const ProductDetailsScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/placeholder.jpg');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Category: ${product.category}'),
                  const SizedBox(height: 8),
                  Text(
                    product.discount > 0
                        ? '\$${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)} (${product.discount}% off)'
                        : '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(product.description),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .addItem(product.id, product.name, product.price, product.image);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.name} added to cart')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}