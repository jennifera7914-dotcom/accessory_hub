import 'package:flutter/material.dart';
import '../models/product.dart';

// This screen shows full details of ONE selected product.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isWishlisted = false; // temporary UI only. Member 1 will handle real wishlist later.

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    bool isInStock = product.stock > 0;
    bool isLowStock = product.stock > 0 && product.stock <= 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE
            Container(
              height: 280,
              width: double.infinity,
              color: Colors.grey[200],
              child: product.image.isEmpty
                  ? Icon(
                      Icons.phone_android,
                      size: 100,
                      color: Colors.grey[400],
                    )
                  : Image.network(
                      product.image,
                      fit: BoxFit.cover,
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRODUCT NAME
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PRICE / MRP
                  Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        'MRP ₹${product.mrp}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // STOCK STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: !isInStock
                          ? Colors.red[50]
                          : isLowStock
                              ? Colors.orange[50]
                              : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !isInStock
                            ? Colors.red
                            : isLowStock
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          !isInStock
                              ? Icons.cancel
                              : isLowStock
                                  ? Icons.warning
                                  : Icons.check_circle,
                          size: 18,
                          color: !isInStock
                              ? Colors.red
                              : isLowStock
                                  ? Colors.orange
                                  : Colors.green,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          !isInStock
                              ? 'Out of Stock'
                              : isLowStock
                                  ? 'Only ${product.stock} left'
                                  : 'In Stock',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !isInStock
                                ? Colors.red
                                : isLowStock
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // QUANTITY SELECTOR
                  const Text(
                    'Select Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Minus button
                      _quantityButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),

                      Container(
                        width: 70,
                        height: 42,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Plus button
                      _quantityButton(
                        icon: Icons.add,
                        onTap: () {
                          if (quantity < product.stock) {
                            setState(() {
                              quantity++;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot select more than available stock'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Total: ₹${product.price * quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DESCRIPTION
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // COMPATIBLE PHONES
                  if (product.compatiblePhones.isNotEmpty) ...[
                    const Text(
                      'Compatible With',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.compatiblePhones.map((phone) {
                        return Chip(
                          label: Text(phone),
                          backgroundColor: Colors.blue[50],
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM BUTTONS
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Wishlist button
            InkWell(
              onTap: () {
                setState(() {
                  isWishlisted = !isWishlisted;
                });

                // Later Member 1 will replace this with real wishlist Firebase code.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isWishlisted
                          ? 'Added to wishlist'
                          : 'Removed from wishlist',
                    ),
                  ),
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Add to Cart
            Expanded(
              child: ElevatedButton(
                onPressed: isInStock
                    ? () {
                        // Later Member 3 will replace this with cart code.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Add to Cart: ${product.name} x $quantity',
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Add to Cart'),
              ),
            ),

            const SizedBox(width: 12),

            // Order Now
            Expanded(
              child: ElevatedButton(
                onPressed: isInStock
                    ? () {
                        // Later Member 3 will replace this with checkout code.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order Now: ${product.name} x $quantity',
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Order Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}