class Product {
  final int id;
  final String name;
  final String description;
  final String brand;
  final String category;
  final double price;
  final double discount;
  final int stockQuantity;
  final bool available;
  final String imageUrl;
  final String thumbnailUrl;
  final double averageRating;
  final int reviewCount;
  final bool visible;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.brand,
    required this.category,
    required this.price,
    required this.discount,
    required this.stockQuantity,
    required this.available,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.averageRating,
    required this.reviewCount,
    required this.visible,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        brand: json['brand'],
        category: json['category'],
        price: (json['price'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        stockQuantity: json['stockQuantity'],
        available: json['available'],
        imageUrl: json['imageUrl'],
        thumbnailUrl: json['thumbnailUrl'],
        averageRating: (json['averageRating'] as num).toDouble(),
        reviewCount: json['reviewCount'],
        visible: json['visible'],
      );
}
