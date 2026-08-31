import 'package:flutter/material.dart';

import '../data/firebase_categories.dart';
import '../data/firebase_products.dart';
import '../models/product.dart';
import '../models/product_category.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController phonesController = TextEditingController();

  String? selectedCategory;

  bool isFeatured = false;
  bool isNewArrival = false;
  bool isSaving = false;

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    mrpController.dispose();
    stockController.dispose();
    phonesController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null || selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      List<String> compatiblePhones = phonesController.text
          .split(',')
          .map((phone) => phone.trim())
          .where((phone) => phone.isNotEmpty)
          .toList();

      Product newProduct = Product(
        id: idController.text.trim(),
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        image: '',
        mrp: int.parse(mrpController.text.trim()),
        stock: int.parse(stockController.text.trim()),
        category: selectedCategory!,
        compatiblePhones: compatiblePhones,
        isFeatured: isFeatured,
        isNewArrival: isNewArrival,
      );

      await FirebaseProducts.addProduct(newProduct);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _textField(
                controller: idController,
                label: 'Product ID',
                hint: 'Example: P004',
              ),

              _textField(
                controller: nameController,
                label: 'Product Name',
                hint: 'Example: iPhone 15 Case',
              ),

              _textField(
                controller: descriptionController,
                label: 'Description',
                hint: 'Write product description',
                maxLines: 3,
              ),

              _textField(
                controller: mrpController,
                label: 'MRP',
                hint: 'Example: 499',
                keyboardType: TextInputType.number,
              ),

              _textField(
                controller: stockController,
                label: 'Stock Quantity',
                hint: 'Example: 500',
                keyboardType: TextInputType.number,
              ),

              _categoryDropdown(),

              const SizedBox(height: 14),

              _textField(
                controller: phonesController,
                label: 'Compatible Phones',
                hint: 'Example: iPhone 15, iPhone 15 Pro',
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show in Featured Products'),
                value: isFeatured,
                onChanged: (value) {
                  setState(() {
                    isFeatured = value;
                  });
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show in New Arrivals'),
                value: isNewArrival,
                onChanged: (value) {
                  setState(() {
                    isNewArrival = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Product',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return StreamBuilder<List<ProductCategory>>(
      stream: FirebaseCategories.getAllCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: LinearProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              'Error loading categories: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        List<ProductCategory> categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Text(
              'No categories found. Add categories first.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.name,
              child: Text('${category.icon} ${category.name}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Category is required';
            }

            return null;
          },
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,

        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          if (keyboardType == TextInputType.number) {
            if (int.tryParse(value.trim()) == null) {
              return 'Enter valid number';
            }
          }

          return null;
        },
      ),
    );
  }
}