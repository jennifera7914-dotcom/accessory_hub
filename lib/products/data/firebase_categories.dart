import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_category.dart';

class FirebaseCategories {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all categories from Firebase
  static Stream<List<ProductCategory>> getAllCategories() {
    return _db.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductCategory.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add new category
  static Future<void> addCategory(ProductCategory category) async {
    await _db.collection('categories').doc(category.id).set(category.toMap());
  }

  // Update existing category
  static Future<void> updateCategory(ProductCategory category) async {
    await _db.collection('categories').doc(category.id).update(category.toMap());
  }

  // Delete category
  static Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }
}