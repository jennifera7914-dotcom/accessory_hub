import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/cloudinary_service.dart';
import '../data/firebase_categories.dart';
import '../data/firebase_products.dart';
import '../models/product.dart';
import '../models/product_category.dart';

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
  late TextEditingController phonesController;

  late String selectedCategory;

  late bool isFeatured;
  late bool isNewArrival;

  bool isSaving = false;

  XFile? selectedImageFile;
  Uint8List? selectedImageBytes;

  // New: if admin wants to remove existing saved image
  bool removeSavedImage = false;

  @override
  void initState() {
    super.initState();

    Product product = widget.product;

    nameController = TextEditingController(text: product.name);
    descriptionController = TextEditingController(text: product.description);
    mrpController = TextEditingController(text: product.mrp.toString());
    stockController = TextEditingController(text: product.stock.toString());
    phonesController = TextEditingController(
      text: product.compatiblePhones.join(', '),
    );

    selectedCategory = product.category;
    isFeatured = product.isFeatured;
    isNewArrival = product.isNewArrival;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    mrpController.dispose();
    stockController.dispose();
    phonesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image == null) {
      return;
    }

    final Uint8List bytes = await image.readAsBytes();

    setState(() {
      selectedImageFile = image;
      selectedImageBytes = bytes;

      // If admin picks new image, cancel remove-image decision.
      removeSavedImage = false;
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String imageUrl = widget.product.image;
      String cloudinaryPublicId = widget.product.cloudinaryPublicId;

      // Case 1: Admin selected a new image
      if (selectedImageFile != null) {
        CloudinaryUploadResult uploadResult =
            await CloudinaryService.uploadProductImage(
          imageFile: selectedImageFile!,
          productId: widget.product.id,
        );

        imageUrl = uploadResult.imageUrl;
        cloudinaryPublicId = uploadResult.publicId;
      }

      // Case 2: Admin wants to remove saved image
      else if (removeSavedImage) {
        imageUrl = '';
        cloudinaryPublicId = '';
      }

      // Case 3: No image change
      // Keep old imageUrl and old cloudinaryPublicId

      List<String> compatiblePhones = phonesController.text
          .split(',')
          .map((phone) => phone.trim())
          .where((phone) => phone.isNotEmpty)
          .toList();

      Product updatedProduct = Product(
        id: widget.product.id,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        image: imageUrl,
        cloudinaryPublicId: cloudinaryPublicId,
        mrp: int.parse(mrpController.text.trim()),
        stock: int.parse(stockController.text.trim()),
        category: selectedCategory,
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

              const SizedBox(height: 20),

              const Text(
                'Product Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _imagePickerBox(),

              const SizedBox(height: 24),

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

  Widget _imagePickerBox() {
    bool hasExistingImage =
        widget.product.image.isNotEmpty && removeSavedImage == false;

    bool hasNewImage = selectedImageBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),

          child: hasNewImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    selectedImageBytes!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                )
              : hasExistingImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _emptyImagePlaceholder(
                            text: 'Image could not load',
                          );
                        },
                      ),
                    )
                  : _emptyImagePlaceholder(
                      text: removeSavedImage
                          ? 'Image will be removed after saving'
                          : 'No image selected',
                    ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: Text(
                hasExistingImage || hasNewImage ? 'Change Image' : 'Pick Image',
              ),
            ),

            if (hasNewImage)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedImageFile = null;
                    selectedImageBytes = null;
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Cancel New Image'),
              ),

            if (hasExistingImage && !hasNewImage)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    removeSavedImage = true;
                    selectedImageFile = null;
                    selectedImageBytes = null;
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Saved Image'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),

            if (removeSavedImage)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    removeSavedImage = false;
                  });
                },
                icon: const Icon(Icons.undo),
                label: const Text('Undo Remove'),
              ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          removeSavedImage
              ? 'Tap Save Changes to remove this image from the product.'
              : 'You can change or remove the product image.',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _emptyImagePlaceholder({required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image,
          size: 55,
          color: Colors.grey[500],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
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

        bool categoryExists = categories.any(
          (category) => category.name == selectedCategory,
        );

        List<DropdownMenuItem<String>> items = categories.map((category) {
          return DropdownMenuItem<String>(
            value: category.name,
            child: Text('${category.icon} ${category.name}'),
          );
        }).toList();

        if (!categoryExists && selectedCategory.isNotEmpty) {
          items.insert(
            0,
            DropdownMenuItem<String>(
              value: selectedCategory,
              child: Text(selectedCategory),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          value: selectedCategory.isEmpty ? null : selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: items,
          onChanged: (value) {
            if (value == null) return;

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