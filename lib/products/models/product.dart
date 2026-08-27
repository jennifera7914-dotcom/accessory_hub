// This file is the blueprint/model for ONE product.

class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final int mrp;
  final int stock;
  final String category;
  final List<String> compatiblePhones;
  final bool isFeatured;
  final bool isNewArrival;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.mrp,
    required this.stock,
    required this.category,
    required this.compatiblePhones,
    required this.isFeatured,
    required this.isNewArrival,
  });

  // Firebase data -> Product object
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      mrp: _toInt(data['mrp']),
      stock: _toInt(data['stock']),
      category: data['category'] ?? '',
      compatiblePhones: List<String>.from(data['compatiblePhones'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      isNewArrival: data['isNewArrival'] ?? false,
    );
  }

  // Product object -> Firebase data
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'mrp': mrp,
      'stock': stock,
      'category': category,
      'compatiblePhones': compatiblePhones,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
    };
  }

  // This safely converts Firebase number into int.
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }
}