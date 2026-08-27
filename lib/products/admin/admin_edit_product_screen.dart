import 'package:flutter/material.dart';

import '../data/firebase_products.dart';
import '../models/product.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product product;

  const AdminEditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController mrpController;
  late TextEditingController stockController;
  late TextEditingController categoryController;
  late TextEditingController phonesController;

  late bool isFeatured;
  late bool isNewArrival;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    Product product = widget.product;

    // Fill fields with existing product values
    nameController = TextEditingController(text: product.name);
    descriptionController = TextEditingController(text: product.description);
    mrpController = TextEditingController(text: product.mrp.toString());
    stockController = TextEditingController(text: product.stock.toString());
    categoryController = TextEditingController(text: product.category);
    phonesController = TextEditingController(
      text: product.compatiblePhones.join(', '),
    );

    isFeatured = product.isFeatured;
    isNewArrival = product.isNewArrival;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    mrpController.dispose();
    stockController.dispose();
    categoryController.dispose();
    phonesController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
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

      Product updatedProduct = Product(
        id: widget.product.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        image: widget.product.image,
        mrp: int.parse(mrpController.text.trim()),
        stock: int.parse(stockController.text.trim()),
        category: categoryController.text.trim(),
        compatiblePhones: compatiblePhones,
        isFeatured: isFeatured,
        isNewArrival: isNewArrival,
      );

      await FirebaseProducts.updateProduct(updatedProduct);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    try {
      await FirebaseProducts.deleteProduct(widget.product.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to delete "${widget.product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProduct();
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

  @override
  Widget build(BuildContext context) {
    Product product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
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
              // Product ID display only
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'Product ID: ${product.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

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

              _textField(
                controller: categoryController,
                label: 'Category',
                hint: 'Example: Cases',
              ),

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
                  onPressed: isSaving ? null : _updateProduct,
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
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete Product'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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