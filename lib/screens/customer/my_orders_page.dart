// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_page.dart';
import '../../data/models/order.dart';
import '../../data/services/firestore_service.dart';

class MyOrdersPage extends StatelessWidget {
  MyOrdersPage({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _buildOrdersBody(context),
    );
  }

  Widget _buildOrdersBody(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Please login to view orders"));
    }

    return StreamBuilder<List<Order>>(
      stream: _firestoreService.streamOrders(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text("No orders placed yet"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _orderCard(context, order);
          },
        );
      },
    );
  }

  // 🧾 ORDER CARD
  Widget _orderCard(BuildContext context, Order order) {
    Color statusColor;
    switch (order.status) {
      case "Delivered":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    IconData paymentIcon;
    switch (order.paymentMethod) {
      case "UPI":
        paymentIcon = Icons.qr_code;
        break;
      case "Card":
        paymentIcon = Icons.credit_card;
        break;
      default:
        paymentIcon = Icons.money;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.15),
          child: const Icon(Icons.receipt_long, color: Colors.blue),
        ),
        title: Text(
          "#${order.id.substring(0, 6).toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: ${_formatDate(order.createdAt)}"),
            Text("Amount: ₹${order.total.toStringAsFixed(0)}"),
            Row(
              children: [
                Icon(paymentIcon, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("Payment: ${order.paymentMethod}"),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order.status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OrderDetailsPage()),
          );
        },
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
