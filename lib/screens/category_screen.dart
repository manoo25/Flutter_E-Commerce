import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'product_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  static const routeName = '/category';

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String?;

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: Text('No category selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FutureBuilder<List<Product>>(
        future: _apiService.getProductsByCategory(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error loading products for category $category: ${snapshot.error}');
            return const Center(child: Text('Failed to load products'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          final products = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Image load error for ${product.image}: $error');
                            return Image.asset('assets/images/placeholder.jpg');
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          product.discount > 0
                              ? '\$${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}'
                              : '\$${product.price.toStringAsFixed(2)}',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addItem(product.id, product.name, product.price, product.image);
                            print('Added to cart: ${product.name}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} added to cart')),
                            );
                          },
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}