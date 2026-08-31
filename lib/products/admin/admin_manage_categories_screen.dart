import 'package:flutter/material.dart';

import '../data/firebase_categories.dart';
import '../data/firebase_products.dart';
import '../models/product.dart';
import '../models/product_category.dart';

class AdminManageCategoriesScreen extends StatelessWidget {
  const AdminManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          _showCategoryDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<ProductCategory>>(
        stream: FirebaseCategories.getAllCategories(),
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categorySnapshot.hasError) {
            return Center(
              child: Text('Error: ${categorySnapshot.error}'),
            );
          }

          List<ProductCategory> categories = categorySnapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'No categories yet.\nTap + to add category.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // We also read all products only to count how many products are in each category.
          return StreamBuilder<List<Product>>(
            stream: FirebaseProducts.getAllProducts(),
            builder: (context, productSnapshot) {
              List<Product> products = productSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  ProductCategory category = categories[index];

                  int productCount = products.where((product) {
                    return product.category == category.name;
                  }).length;

                  return _categoryCard(
                    context: context,
                    category: category,
                    productCount: productCount,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _categoryCard({
    required BuildContext context,
    required ProductCategory category,
    required int productCount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            // Category icon box
            Container(
              height: 55,
              width: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),

            const SizedBox(width: 12),

            // Category name and count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$productCount products',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _showCategoryDialog(
                  context,
                  existingCategory: category,
                );
              },
            ),

            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _confirmDeleteCategory(
                  context: context,
                  category: category,
                  productCount: productCount,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context, {
    ProductCategory? existingCategory,
  }) {
    bool isEditing = existingCategory != null;

    TextEditingController idController = TextEditingController(
      text: existingCategory?.id ?? '',
    );

    TextEditingController nameController = TextEditingController(
      text: existingCategory?.name ?? '',
    );

    TextEditingController iconController = TextEditingController(
      text: existingCategory?.icon ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: 'Category ID',
                      hintText: 'Example: CAT001',
                    ),
                  ),

                const SizedBox(height: 12),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'Example: Cases',
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon / Emoji',
                    hintText: 'Example: 📱',
                  ),
                ),
              ],
            ),
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
                String id = idController.text.trim();
                String name = nameController.text.trim();
                String icon = iconController.text.trim();

                if (!isEditing && id.isEmpty) {
                  _showMessage(context, 'Category ID is required');
                  return;
                }

                if (name.isEmpty) {
                  _showMessage(context, 'Category name is required');
                  return;
                }

                ProductCategory category = ProductCategory(
                  id: isEditing ? existingCategory.id : id,
                  name: name,
                  icon: icon.isEmpty ? '📦' : icon,
                );

                if (isEditing) {
                  await FirebaseCategories.updateCategory(category);
                } else {
                  await FirebaseCategories.addCategory(category);
                }

                if (context.mounted) {
                  Navigator.pop(context);

                  _showMessage(
                    context,
                    isEditing
                        ? 'Category updated successfully'
                        : 'Category added successfully',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCategory({
    required BuildContext context,
    required ProductCategory category,
    required int productCount,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category?'),

          content: Text(
            productCount > 0
                ? '"${category.name}" has $productCount products.\n\nPlease move/delete those products before deleting this category.'
                : 'Are you sure you want to delete "${category.name}"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            if (productCount == 0)
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await FirebaseCategories.deleteCategory(category.id);

                  if (context.mounted) {
                    _showMessage(context, 'Category deleted successfully');
                  }
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}