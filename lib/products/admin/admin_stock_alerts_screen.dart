import 'package:flutter/material.dart';

import '../data/firebase_products.dart';
import '../models/product.dart';

class AdminStockAlertsScreen extends StatelessWidget {
  const AdminStockAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Alerts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<List<Product>>(
        stream: FirebaseProducts.getAllProducts(),
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

          List<Product> products = snapshot.data ?? [];

          List<Product> outOfStock = products.where((product) {
            return product.stock == 0;
          }).toList();

          List<Product> lowStock = products.where((product) {
            return product.stock > 0 && product.stock <= 10;
          }).toList();

          int totalAlerts = outOfStock.length + lowStock.length;

          if (totalAlerts == 0) {
            return const Center(
              child: Text(
                'All products have enough stock ✅',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Header alert count
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$totalAlerts products need attention',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Out of stock section
              if (outOfStock.isNotEmpty) ...[
                const Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 8),

                ...outOfStock.map((product) {
                  return _stockCard(
                    context: context,
                    product: product,
                    color: Colors.red,
                    icon: Icons.cancel,
                    label: 'Out of Stock',
                  );
                }),

                const SizedBox(height: 20),
              ],

              // Low stock section
              if (lowStock.isNotEmpty) ...[
                const Text(
                  'LOW STOCK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 8),

                ...lowStock.map((product) {
                  return _stockCard(
                    context: context,
                    product: product,
                    color: Colors.orange,
                    icon: Icons.warning,
                    label: 'Low Stock',
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _stockCard({
    required BuildContext context,
    required Product product,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product.image.isEmpty
                  ? Icon(
                      Icons.phone_android,
                      size: 30,
                      color: Colors.grey[500],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image,
                            size: 30,
                            color: Colors.grey[500],
                          );
                        },
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Details
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

                  Text(
                    'Category: ${product.category}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'MRP ₹${product.mrp}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${product.stock} • $label',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: () {
                      _showUpdateStockDialog(context, product);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Stock'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, Product product) {
    TextEditingController stockController = TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Stock'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New Stock Quantity',
                  hintText: 'Example: 50',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
                int? newStock = int.tryParse(stockController.text.trim());

                if (newStock == null || newStock < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter valid stock number'),
                    ),
                  );
                  return;
                }

                Product updatedProduct = Product(
                  id: product.id,
                  name: product.name,
                  description: product.description,
                  image: product.image,
                  mrp: product.mrp,
                  stock: newStock,
                  category: product.category,
                  compatiblePhones: product.compatiblePhones,
                  isFeatured: product.isFeatured,
                  isNewArrival: product.isNewArrival,
                );

                await FirebaseProducts.updateProduct(updatedProduct);

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock updated successfully'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}