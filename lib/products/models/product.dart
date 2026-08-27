// This file is the blueprint for ONE product.
// Every product in our app will follow this format.

class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final int price;
  final int mrp;
  final double rating;
  final int soldCount;
  final int stock;
  final String category;
  final List<String> compatiblePhones;

  // These are extra fields for Firebase
  final bool isFeatured;
  final bool isNewArrival;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.soldCount,
    required this.stock,
    required this.category,
    required this.compatiblePhones,
    this.isFeatured = false,
    this.isNewArrival = false,
  });

  // This creates a Product object from Firebase data
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      price: _toInt(data['price']),
      mrp: _toInt(data['mrp']),
      rating: _toDouble(data['rating']),
      soldCount: _toInt(data['soldCount']),
      stock: _toInt(data['stock']),
      category: data['category'] ?? '',
      compatiblePhones: List<String>.from(data['compatiblePhones'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      isNewArrival: data['isNewArrival'] ?? false,
    );
  }

  // This converts Product object into Firebase data
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'mrp': mrp,
      'rating': rating,
      'soldCount': soldCount,
      'stock': stock,
      'category': category,
      'compatiblePhones': compatiblePhones,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
    };
  }

  // Small helper: Firebase number → int
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  // Small helper: Firebase number → double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}