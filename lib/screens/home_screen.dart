import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
import 'profile_screen.dart'; // تأكد أنك عامل الصفحة دي
import 'dart:math';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _activeIndex = 0;
  String? _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((p) {
        final matchesQuery = query.isEmpty || p.name.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Future<void> _fetchData() async {
    try {
      final apiService = ApiService();
      final fetchedCategories = await apiService.getCategories();
      final fetchedProducts = await apiService.getProducts();

      setState(() {
        categories = [Category(name: 'All')] + fetchedCategories;
        products = fetchedProducts;
        filteredProducts = fetchedProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMenuSelection(String value) async {
    if (value == 'profile') {
      Navigator.pushNamed(context, ProfileScreen.routeName);
    } else if (value == 'logout') {
      await AuthService.clearUserData();
      Navigator.pushReplacementNamed(context, '/login'); // تأكد أن عندك مسار login
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
                prefixIcon: Icon(Icons.search, color: Colors.pink),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.pink),
              ),
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: CircleAvatar(
  radius: 20,
  backgroundColor: Colors.grey[200],
  backgroundImage: const AssetImage('assets/images/placeholder.jpg'),
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
          ? Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
              ? Center(child: Text('No products found.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      CarouselSlider.builder(
                        itemCount: products.isNotEmpty ? min(products.length, 5) : 0,
                        itemBuilder: (context, index, realIndex) {
                          final product = products[index];
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
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  product.image ?? '',
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.network(
                                       "https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg",
                                      fit: BoxFit.contain,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: 180.0,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) =>
                              setState(() => _activeIndex = index),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (products.isNotEmpty)
                        AnimatedSmoothIndicator(
                          key: ValueKey('smoothIndicator'),
                          activeIndex: _activeIndex,
                          count: min(products.length, 5),
                          effect: ExpandingDotsEffect(
                            activeDotColor: Colors.pink,
                            dotColor: Colors.grey.shade300,
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      SizedBox(height: 16),
                      if (categories.isNotEmpty)
                        Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = _selectedCategory == category.name;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category.name;
                                    _onSearchChanged();
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.pink : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        padding: EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final discountedPrice = product.price * (1 - product.discount / 100);
                          return SizedBox(
                            height: 250,
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(8),
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
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            product.image ?? '',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.network(
                                               "https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg",
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      product.name,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${discountedPrice}',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (product.discount > 0)
                                          Text(
                                            '${product.discount}% off',
                                            style: TextStyle(color: Colors.green),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: () {
                                          Provider.of<CartProvider>(context, listen: false).addToCart(product, 1);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${product.name} added to cart')),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.pink,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.add, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (_, cart, __) => BottomNavigationBar(
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
      ),
    );
  }
}
