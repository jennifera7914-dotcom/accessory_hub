import 'package:flutter/material.dart';

import '../data/firebase_products.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // This holds whatever user types
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search accessories...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
        ),
      ),

      body: StreamBuilder<List<Product>>(
        stream: FirebaseProducts.getAllProducts(),
        builder: (context, snapshot) {
          // 1. Loading products from Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // 3. No products in Firebase
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No products available',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          List<Product> allProducts = snapshot.data!;

          // If user has not typed anything
          if (query.isEmpty) {
            return const Center(
              child: Text(
                'Start typing to search...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          String search = query.toLowerCase();

          // Search by name, category, and compatible phone
          List<Product> results = allProducts.where((product) {
            bool matchesName =
                product.name.toLowerCase().contains(search);

            bool matchesCategory =
                product.category.toLowerCase().contains(search);

            bool matchesPhone = product.compatiblePhones.any((phone) {
              return phone.toLowerCase().contains(search);
            });

            return matchesName || matchesCategory || matchesPhone;
          }).toList();

          // If no matching result
          if (results.isEmpty) {
            return const Center(
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Show search results
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return ProductCard(product: results[index]);
              },
            ),
          );
        },
      ),
    );
  }
}