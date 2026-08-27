import 'package:flutter/material.dart';

import '../data/firebase_products.dart';
import '../models/product.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  String searchText = '';
  String selectedCategory = 'All';
  String selectedSort = 'Name A-Z';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add Product screen will be built next'),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Product>>(
        stream: FirebaseProducts.getAllProducts(),
        builder: (context, snapshot) {
          // While Firebase is loading products
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If Firebase gives error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // If no products exist
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          List<Product> allProducts = snapshot.data!;

          // Make category list from Firebase products
          List<String> categories = [
            'All',
            ...allProducts.map((product) => product.category).toSet(),
          ];

          // Apply search and category filter
          List<Product> visibleProducts = allProducts.where((product) {
            bool matchesSearch = product.name
                .toLowerCase()
                .contains(searchText.toLowerCase());

            bool matchesCategory = selectedCategory == 'All' ||
                product.category == selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          // Apply sorting
          _sortProducts(visibleProducts);

          return Column(
            children: [
              // Search box
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),

              // Category filter chips
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    bool isSelected = selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Count and sort row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${visibleProducts.length}',
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
                          value: 'Price Low-High',
                          child: Text('Price Low-High'),
                        ),
                        DropdownMenuItem(
                          value: 'Price High-Low',
                          child: Text('Price High-Low'),
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
              ),

              // Product list
              Expanded(
                child: visibleProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'No matching products',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: visibleProducts.length,
                        itemBuilder: (context, index) {
                          Product product = visibleProducts[index];

                          return _adminProductCard(product);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sortProducts(List<Product> products) {
    if (selectedSort == 'Name A-Z') {
      products.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSort == 'Price Low-High') {
      products.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == 'Price High-Low') {
      products.sort((a, b) => b.price.compareTo(a.price));
    } else if (selectedSort == 'Stock Low-High') {
      products.sort((a, b) => a.stock.compareTo(b.stock));
    }
  }

  Widget _adminProductCard(Product product) {
    Color stockColor;
    IconData stockIcon;
    String stockText;

    if (product.stock == 0) {
      stockColor = Colors.red;
      stockIcon = Icons.cancel;
      stockText = 'Out of Stock';
    } else if (product.stock <= 10) {
      stockColor = Colors.orange;
      stockIcon = Icons.warning;
      stockText = 'Low Stock';
    } else {
      stockColor = Colors.green;
      stockIcon = Icons.check_circle;
      stockText = 'In Stock';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.image.isEmpty
                  ? Icon(
                      Icons.phone_android,
                      size: 35,
                      color: Colors.grey[500],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MRP ₹${product.mrp}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Category: ${product.category}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(stockIcon, color: stockColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${product.stock} • $stockText',
                        style: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Edit ${product.name} will be built next',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),

                      const SizedBox(width: 8),

                      OutlinedButton.icon(
                        onPressed: () {
                          _confirmDelete(product);
                        },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to delete "${product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await FirebaseProducts.deleteProduct(product.id);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} deleted'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}