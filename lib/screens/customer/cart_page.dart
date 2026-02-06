// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_page.dart';
import '../../data/models/cart_item.dart';
import '../../data/services/firestore_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _buildCartBody(context),
    );
  }

  Widget _buildCartBody(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Please login to view your cart"));
    }

    return StreamBuilder<List<CartItem>>(
      stream: _firestoreService.streamCart(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final cartItems = snapshot.data ?? [];
        if (cartItems.isEmpty) {
          return const Center(
            child: Text("Your cart is empty", style: TextStyle(fontSize: 16)),
          );
        }
        final totalAmount = cartItems.fold<double>(
          0,
          (sum, item) => sum + item.total,
        );
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return _cartItemCard(userId, item);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹${totalAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              cartItems: cartItems,
                              totalAmount: totalAmount,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Proceed to Checkout",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 🧾 CART ITEM CARD
  Widget _cartItemCard(String userId, CartItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.shopping_bag, color: Colors.blue),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "₹${item.price.toStringAsFixed(0)} x ${item.quantity} = "
          "₹${item.total.toStringAsFixed(0)}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ➖
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () async {
                await _firestoreService.updateCartItem(
                  userId: userId,
                  cartItemId: item.id,
                  quantity: item.quantity - 1,
                );
              },
            ),

            Text("${item.quantity}"),

            // ➕
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await _firestoreService.updateCartItem(
                  userId: userId,
                  cartItemId: item.id,
                  quantity: item.quantity + 1,
                );
              },
            ),

            // 🗑 REMOVE
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _firestoreService.removeCartItem(
                  userId: userId,
                  cartItemId: item.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
