// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/address.dart';
import '../../data/models/cart_item.dart';
import '../../data/services/firestore_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  final List<CartItem> cartItems;
  final double totalAmount;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = "COD";
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📍 DELIVERY ADDRESS
            _sectionCard(
              title: "Delivery Address",
              child: _buildAddressSection(),
            ),

            const SizedBox(height: 15),

            // 🛒 ORDER SUMMARY
            _sectionCard(
              title: "Order Summary",
              child: Column(
                children: [
                  ...widget.cartItems.map(
                    (item) => _RowText(
                      "${item.name} (${item.quantity} ${item.unit})",
                      "₹${item.total.toStringAsFixed(0)}",
                    ),
                  ),
                  const Divider(),
                  _RowText(
                    "Total Amount",
                    "₹${widget.totalAmount.toStringAsFixed(0)}",
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 💳 PAYMENT METHOD
            _sectionCard(
              title: "Payment Method",
              child: Column(
                children: [
                  RadioListTile(
                    value: "COD",
                    groupValue: _selectedPayment,
                    title: const Text("Cash on Delivery"),
                    onChanged: (val) {
                      setState(() => _selectedPayment = val.toString());
                    },
                  ),
                  RadioListTile(
                    value: "UPI",
                    groupValue: _selectedPayment,
                    title: const Text("UPI / Online Payment"),
                    onChanged: (val) {
                      setState(() => _selectedPayment = val.toString());
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  "Place Order",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await _placeOrder();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Text("Please login to select address");
    }

    return StreamBuilder<List<Address>>(
      stream: _firestoreService.streamAddresses(userId),
      builder: (context, snapshot) {
        final addresses = snapshot.data ?? [];
        Address? selected;
        if (addresses.isNotEmpty) {
          selected = addresses.firstWhere(
            (address) => address.isDefault,
            orElse: () => addresses.first,
          );
        }
        if (selected == null) {
          return const Text("No address saved yet");
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selected.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(selected.formatted),
            Text("📞 ${selected.phone}"),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showError("Please login to place an order");
      return;
    }

    if (widget.cartItems.isEmpty) {
      _showError("Cart is empty");
      return;
    }

    await _firestoreService.createOrder(
      userId: userId,
      items: widget.cartItems,
      total: widget.totalAmount,
      paymentMethod: _selectedPayment,
    );
    await _firestoreService.clearCart(userId);

    if (!mounted) {
      return;
    }
    _showSuccessDialog(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 📦 SECTION CARD
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  // 🎉 SUCCESS DIALOG
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Order Placed"),
        content: const Text(
          "Your order has been placed successfully.\n\nThank you for shopping!",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// 🔹 REUSABLE ROW TEXT
class _RowText extends StatelessWidget {
  final String left;
  final String right;
  final bool bold;

  const _RowText(this.left, this.right, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            right,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
