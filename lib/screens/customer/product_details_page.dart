// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/product.dart';
import '../../data/services/firestore_service.dart';

class ProductDetailsPage extends StatelessWidget {
  ProductDetailsPage({super.key, required this.product});

  final Product product;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 PRODUCT IMAGE (UI DEMO)
            Center(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🏷 PRODUCT NAME
            Text(
              product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // CATEGORY
            Chip(
              label: Text(product.category),
              backgroundColor: const Color(0xFFD6EAF8),
              labelStyle: const TextStyle(color: Colors.blue),
            ),

            const SizedBox(height: 12),

            // 💰 PRICE
            Text(
              "₹${product.price.toStringAsFixed(0)} / ${product.unit}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ RATING
            Row(
              children: const [
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star, color: Colors.orange, size: 20),
                Icon(Icons.star_half, color: Colors.orange, size: 20),
                Icon(Icons.star_border, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text("3.5 / 5"),
              ],
            ),

            const SizedBox(height: 20),

            // 📄 DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              product.description?.isNotEmpty == true
                  ? product.description!
                  : "Fresh produce directly from verified farmers.",
              style: const TextStyle(height: 1.4),
            ),

            const SizedBox(height: 20),

            // 🚚 DELIVERY INFO
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.local_shipping, color: Colors.blue),
                title: Text("Free Delivery"),
                subtitle: Text("Delivered within 2–3 days"),
              ),
            ),

            const SizedBox(height: 25),

            // 🛒 ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Add to Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId == null) {
                        _showSnack(context, "Please login to add items to cart");
                        return;
                      }
                      await _firestoreService.addToCart(
                        userId: userId,
                        product: product,
                      );
                      _showSnack(context, "Added to cart");
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Wishlist"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId == null) {
                        _showSnack(
                          context,
                          "Please login to add items to wishlist",
                        );
                        return;
                      }
                      await _firestoreService.addToWishlist(
                        userId: userId,
                        product: product,
                      );
                      _showSnack(context, "Added to wishlist");
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ⚡ BUY NOW
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Proceed to checkout from cart");
                },
                child: const Text("Buy Now", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔔 SNACKBAR
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
