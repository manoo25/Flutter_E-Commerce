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
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      price: (json['price'] is int ? (json['price'] as int).toDouble() : json['price'] as double?) ?? 0.0,
      image: json['image']?.toString() ?? 'https://ib.jamalmoallart.com/placeholder.jpg',
      discount: (json['discount'] is int ? (json['discount'] as int).toDouble() : json['discount'] as double?) ?? 0.0,
      category: json['category']?.toString() ?? 'Uncategorized',
      description: json['description']?.toString() ?? 'No description available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'discount': discount,
      'category': category,
      'description': description,
    };
  }
}