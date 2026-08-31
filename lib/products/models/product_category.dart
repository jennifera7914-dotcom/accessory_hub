class ProductCategory {
  final String id;
  final String name;
  final String icon;

  ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  // Firebase data -> ProductCategory object
  factory ProductCategory.fromMap(String id, Map<String, dynamic> data) {
    return ProductCategory(
      id: id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '📦',
    );
  }

  // ProductCategory object -> Firebase data
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}