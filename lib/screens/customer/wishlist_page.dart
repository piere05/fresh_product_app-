// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/product.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/services/firestore_service.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: _buildWishlistBody(context),
    );
  }

  Widget _buildWishlistBody(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Please login to view wishlist"));
    }
    return StreamBuilder<List<WishlistItem>>(
      stream: _firestoreService.streamWishlist(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text("Your wishlist is empty"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _wishlistCard(context, userId, items[index]);
          },
        );
      },
    );
  }

  // ❤️ WISHLIST CARD
  Widget _wishlistCard(
    BuildContext context,
    String userId,
    WishlistItem item,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: const Icon(Icons.favorite, color: Colors.pink),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Category: ${item.category}\n"
          "Price: ₹${item.price.toStringAsFixed(0)} / ${item.unit}",
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.green),
              tooltip: "Add to Cart",
              onPressed: () async {
                final product = Product(
                  id: item.productId,
                  name: item.name,
                  category: item.category,
                  price: item.price,
                  unit: item.unit,
                  quantity: 0,
                  farmerId: item.farmerId ?? '',
                  inStock: true,
                );
                await _firestoreService.addToCart(
                  userId: userId,
                  product: product,
                );
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${item.name} added to cart")),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Remove",
              onPressed: () async {
                await _firestoreService.removeFromWishlist(
                  userId: userId,
                  productId: item.productId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
