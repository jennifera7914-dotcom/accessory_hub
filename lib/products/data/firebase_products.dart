import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseProducts {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // Later admin screen will use this
  static Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  // Later admin screen will use this
  static Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  // Later admin screen will use this
  static Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}