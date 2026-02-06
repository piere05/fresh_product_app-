// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/product.dart';
import '../../data/services/firestore_service.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  FirestoreService get _firestoreService => FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("My Products"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Please login to view products"));
    }

    return StreamBuilder<List<Product>>(
      stream: _firestoreService.streamFarmerProducts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text("No products added yet"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _productCard(context, products[index]);
          },
        );
      },
    );
  }

  // 📦 PRODUCT CARD
  Widget _productCard(BuildContext context, Product product) {
    final stockLabel = product.inStock ? 'In Stock' : 'Out of Stock';
    final stockColor = product.inStock ? Colors.green : Colors.red;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.15),
          child: const Icon(Icons.shopping_bag, color: Colors.green),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "₹${product.price.toStringAsFixed(0)} / ${product.unit}",
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stockLabel,
              style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: () {
                    _showSnack(context, "Edit ${product.name} coming soon");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () {
                    _confirmDelete(context, product);
                  },
                ),
              ],
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

  // 🗑 DELETE CONFIRMATION
  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: Text("Are you sure you want to delete ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestoreService.deleteProduct(product.id);
              if (!context.mounted) {
                return;
              }
              _showSnack(context, "${product.name} deleted");
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
