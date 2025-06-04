import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  List<Product> products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final apiService = ApiService();
      final fetchedCategories = await apiService.getCategories();
      final fetchedProducts = await apiService.getProducts();

      setState(() {
        categories = fetchedCategories;
        products = fetchedProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products available.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 200.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          enlargeCenterPage: true,
                        ),
                        items: products.take(5).map((product) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    ProductDetailsScreen.route,
                                    arguments: product,
                                  );
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      product.image ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/placeholder.jpg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text('Womens', style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text('Handbags', style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text('Boots', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        padding: EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final discountedPrice = product.price * (1 - product.discount / 100);
                          return Card(
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        ProductDetailsScreen.route,
                                        arguments: product,
                                      );
                                    },
                                    child: Image.network(
                                      product.image ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/placeholder.jpg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${discountedPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (product.discount > 0)
                                        Text(
                                          '${product.discount}% off',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Provider.of<CartProvider>(context, listen: false)
                                              .addToCart(product, 1);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${product.name} added to cart')),
                                          );
                                        },
                                        child: Text('Add to Cart'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
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
              // Already on home
              break;
            case 1:
              Navigator.pushNamed(context, CartScreen.routeName);
              break;
            case 2:
              Navigator.pushNamed(context, OrdersScreen.routeName);
              break;
          }
        },
      ),
    );
  }
}