import 'package:flutter/material.dart';

import '../data/firebase_products.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

// This screen shows products in a grid.
// If category is given, show only that category.
// If category is not given, show all products.
class CategoryScreen extends StatefulWidget {
  final String? category;

  const CategoryScreen({
    super.key,
    this.category,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String selectedStockFilter = 'All';
  String selectedSort = 'Name A-Z';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? 'All Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<Product>>(
        stream: widget.category == null
            ? FirebaseProducts.getAllProducts()
            : FirebaseProducts.getProductsByCategory(widget.category!),

        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                widget.category == null
                    ? 'No products found'
                    : 'No products found in ${widget.category}',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          List<Product> products = snapshot.data!;

          // Apply stock filter
          List<Product> visibleProducts = products.where((product) {
            if (selectedStockFilter == 'In Stock') {
              return product.stock > 10;
            } else if (selectedStockFilter == 'Low Stock') {
              return product.stock > 0 && product.stock <= 10;
            } else if (selectedStockFilter == 'Out of Stock') {
              return product.stock == 0;
            } else {
              return true;
            }
          }).toList();

          // Apply sort
          _sortProducts(visibleProducts);

          return Column(
            children: [
              // Filter/sort section
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Stock filter chips
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _filterChip('All'),
                          _filterChip('In Stock'),
                          _filterChip('Low Stock'),
                          _filterChip('Out of Stock'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Count + sort dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${visibleProducts.length} products',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        DropdownButton<String>(
                          value: selectedSort,
                          items: const [
                            DropdownMenuItem(
                              value: 'Name A-Z',
                              child: Text('Name A-Z'),
                            ),
                            DropdownMenuItem(
                              value: 'MRP Low-High',
                              child: Text('MRP Low-High'),
                            ),
                            DropdownMenuItem(
                              value: 'MRP High-Low',
                              child: Text('MRP High-Low'),
                            ),
                            DropdownMenuItem(
                              value: 'Stock Low-High',
                              child: Text('Stock Low-High'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedSort = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Product grid
              Expanded(
                child: visibleProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'No products match this filter',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: visibleProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: visibleProducts[index],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = selectedStockFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
        onSelected: (selected) {
          setState(() {
            selectedStockFilter = label;
          });
        },
      ),
    );
  }

  void _sortProducts(List<Product> products) {
    if (selectedSort == 'Name A-Z') {
      products.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSort == 'MRP Low-High') {
      products.sort((a, b) => a.mrp.compareTo(b.mrp));
    } else if (selectedSort == 'MRP High-Low') {
      products.sort((a, b) => b.mrp.compareTo(a.mrp));
    } else if (selectedSort == 'Stock Low-High') {
      products.sort((a, b) => a.stock.compareTo(b.stock));
    }
  }
}