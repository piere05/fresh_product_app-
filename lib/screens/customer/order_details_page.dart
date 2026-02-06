// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import '../../data/models/order.dart';

class OrderDetailsPage extends StatelessWidget {
  OrderDetailsPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📦 ORDER STATUS
            _sectionCard(
              title: "Order Status",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.status,
                    style: TextStyle(
                      color: order.status == "Delivered"
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Chip(
                    label: Text(order.paymentMethod),
                    backgroundColor: const Color(0xFFDFF5E3),
                    labelStyle: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🧾 ORDER INFO
            _sectionCard(
              title: "Order Information",
              child: Column(
                children: [
                  _InfoRow(
                    "Order ID",
                    "#${order.id.substring(0, 6).toUpperCase()}",
                  ),
                  _InfoRow("Order Date", _formatDate(order.createdAt)),
                  _InfoRow("Payment", order.paymentMethod),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🛒 PRODUCT DETAILS
            _sectionCard(
              title: "Products",
              child: Column(
                children: [
                  ...order.items.map(
                    (item) => _ProductRow(
                      item.name,
                      "${item.quantity} ${item.unit}",
                      "₹${item.total.toStringAsFixed(0)}",
                    ),
                  ),
                  const Divider(),
                  _InfoRow(
                    "Total Amount",
                    "₹${order.total.toStringAsFixed(0)}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 🚚 DELIVERY ADDRESS
            _sectionCard(
              title: "Delivery Address",
              child: Text(
                order.userId,
                style: const TextStyle(height: 1.5),
              ),
            ),

            const SizedBox(height: 25),

            // 🔄 ACTION BUTTONS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt),
                label: const Text("Download Invoice"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Invoice download coming soon");
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text("Need Help"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showSnack(context, "Support coming soon");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📌 SECTION CARD
  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            child,
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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

// 🧾 INFO ROW
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 🛒 PRODUCT ROW
class _ProductRow extends StatelessWidget {
  final String name;
  final String qty;
  final String price;

  const _ProductRow(this.name, this.qty, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(name), Text(qty), Text(price)],
      ),
    );
  }
}
