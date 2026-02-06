import 'package:flutter/material.dart';
import '../../data/models/order.dart';
import '../../data/services/firestore_service.dart';

class OrderDetailsPage extends StatelessWidget {
  OrderDetailsPage({super.key, required this.order});

  final Order order;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧾 ORDER SUMMARY
            _sectionCard(
              title: "Order Summary",
              child: Column(
                children: [
                  _InfoRow(
                    "Order ID",
                    "#${order.id.substring(0, 6).toUpperCase()}",
                  ),
                  _InfoRow("Order Date", _formatDate(order.createdAt)),
                  _InfoRow("Status", order.status),
                  _InfoRow("Payment", order.paymentMethod),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 👤 CUSTOMER DETAILS
            _sectionCard(
              title: "Customer Details",
              child: Column(
                children: [
                  _InfoRow("User ID", order.userId),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 📦 PRODUCT DETAILS
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

            const SizedBox(height: 25),

            // ✅ ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _firestoreService.updateOrderStatus(
                        orderId: order.id,
                        status: "Approved",
                      );
                      if (!context.mounted) {
                        return;
                      }
                      _showSnack(context, "Order approved");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _firestoreService.updateOrderStatus(
                        orderId: order.id,
                        status: "Cancelled",
                      );
                      if (!context.mounted) {
                        return;
                      }
                      _showSnack(context, "Order cancelled");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🚚 MARK AS DELIVERED
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _firestoreService.updateOrderStatus(
                    orderId: order.id,
                    status: "Delivered",
                  );
                  if (!context.mounted) {
                    return;
                  }
                  _showSnack(context, "Order delivered");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Mark as Delivered"),
              ),
            ),

            const SizedBox(height: 10),

            // ❌ CANCEL ORDER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirmCancel(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Cancel Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔲 SECTION CARD
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

  // ❗ CANCEL CONFIRMATION
  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              await _firestoreService.updateOrderStatus(
                orderId: order.id,
                status: "Cancelled",
              );
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
              _showSnack(context, "Order cancelled");
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
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

// 🔹 INFO ROW WIDGET
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

// 🔹 PRODUCT ROW WIDGET
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
