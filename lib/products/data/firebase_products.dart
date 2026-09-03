import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class FirebaseProducts {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new automatic product ID.
  // This does NOT save anything yet.
  // It only gives us a unique ID.
  static String createProductId() {
    return _db.collection('products').doc().id;
  }

  // Get all products from Firebase
  static Stream<List<Product>> getAllProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Get products by category
  static Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Add product to Firebase
  static Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  // Update product in Firebase
  static Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  // Delete product from Firebase
  static Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}