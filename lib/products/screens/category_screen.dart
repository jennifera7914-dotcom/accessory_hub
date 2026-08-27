import 'package:flutter/material.dart';

import '../data/firebase_products.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

// This screen shows products in a grid.
// If category is given, show only that category.
// If category is not given, show all products.
class CategoryScreen extends StatelessWidget {
  final String? category;

  const CategoryScreen({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category ?? 'All Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<Product>>(
        stream: category == null
            ? FirebaseProducts.getAllProducts()
            : FirebaseProducts.getProductsByCategory(category!),

        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // 3. No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                category == null
                    ? 'No products found'
                    : 'No products found in $category',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          // 4. Products from Firebase
          List<Product> products = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}