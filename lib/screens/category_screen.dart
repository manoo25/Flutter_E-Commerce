// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../models/product_model.dart';
// import 'product_details_screen.dart';

// class CategoryScreen extends StatefulWidget {
//   static const String routeName = "/category";

//   @override
//   _CategoryScreenState createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<CategoryScreen> {
//   List<Product> products = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProducts();
//   }

//   Future<void> _fetchProducts() async {
//     try {
//       final categoryName = ModalRoute.of(context)!.settings.arguments as String;
//       final apiService = ApiService();
//       final fetchedProducts = await apiService.getProductsByCategory(categoryName);
//       print('Products for category $categoryName: $fetchedProducts');
//       setState(() {
//         products = fetchedProducts;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching products: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categoryName = ModalRoute.of(context)!.settings.arguments as String;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(categoryName),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : products.isEmpty
//               ? const Center(child: Text('No products found'))
//               : GridView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 0.7,
//                   ),
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     final discountedPrice = product.price * (1 - product.discount / 100);
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(
//                           context,
//                           ProductDetailsScreen.route,
//                           arguments: product,
//                         );
//                       },
//                       child: Card(
//                         child: Column(
//                           children: [
//                             Image.network(
//                               product.image ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
//                               height: 100,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 print('Image load error: $error, URL: ${product.image}');
//                                 return Image.asset(
//                                   'assets/images/placeholder.jpg',
//                                   height: 100,
//                                   fit: BoxFit.cover,
//                                 );
//                               },
//                             ),
//                             Text(product.name),
//                             Text(
//                               '\$${discountedPrice.toStringAsFixed(2)}',
//                               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                     color: Theme.of(context).colorScheme.primary,
//                                   ),
//                             ),
//                             if (product.discount > 0)
//                               Text(
//                                 '${product.discount}% off',
//                                 style: const TextStyle(color: Colors.green),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }