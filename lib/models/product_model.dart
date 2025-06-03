class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final double discount;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.discount,
    required this.category,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? json['name']?.toString() ?? 'No Name',
      price: (json['price'] is int ? (json['price'] as int).toDouble() : json['price'] as double?) ?? 0.0,
      image: json['imageCover']?.toString() ?? json['image']?.toString() ?? 'https://ecommerce.routemisr.com/Route-Academy-products/1678305677165-cover.jpeg',
      discount: (json['discount'] is int ? (json['discount'] as int).toDouble() : json['discount'] as double?) ?? 0.0,
      category: json['category']?['name']?.toString() ?? json['category']?.toString() ?? 'Uncategorized',
      description: json['description']?.toString() ?? 'No description available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': name,
      'price': price,
      'imageCover': image,
      'discount': discount,
      'category': category,
      'description': description,
    };
  }
}