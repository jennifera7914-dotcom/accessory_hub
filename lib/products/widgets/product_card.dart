import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';  // ← NEW: so this file knows about the detail screen

// This is ONE product card. It takes a Product and draws it on screen.
class ProductCard extends StatelessWidget {
  final Product product;  // the product data we receive

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // First, figure out stock status
    bool isInStock = product.stock > 0;
    bool isLowStock = product.stock > 0 && product.stock <= 10;

    return GestureDetector(   // ← NEW: makes the whole card tappable
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 170,  // fixed width for grid layout
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),  // rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),  // shadow goes slightly down
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,  // align left
          children: [

            // ═══════════════════════════════════════
            // TOP SECTION: Image + Heart + Stock Badge
            // ═══════════════════════════════════════
            Stack(
              children: [
                // Product image placeholder (grey box with icon)
                Container(
                  height: 140,
                  width: double.infinity,  // fill full width
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),

                // Wishlist heart button (top-right corner)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),

                // Stock badge (bottom-left of image)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // Green if in stock, Orange if low, Red if out
                      color: !isInStock
                          ? Colors.red
                          : isLowStock
                              ? Colors.orange
                              : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      !isInStock
                          ? 'Out of Stock'
                          : isLowStock
                              ? 'Only ${product.stock} left'
                              : 'In Stock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ═══════════════════════════════════════
            // BOTTOM SECTION: Name, Rating, Price
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Product name (max 2 lines, then "...")
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),  // small gap

                  // Rating star + sold count (side by side)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        ' ${product.rating}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      Text(
                        ' | ${product.soldCount} sold',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Price row: selling price + MRP strikethrough
                  Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${product.mrp}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[500],
                          fontSize: 12,
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
}