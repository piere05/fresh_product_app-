import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_page.dart';
import '../../data/models/order.dart';
import '../../data/services/firestore_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: "Search orders...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📋 ORDER LIST
          Expanded(
            child: _buildOrders(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrders(BuildContext context) {
    final farmerId = FirebaseAuth.instance.currentUser?.uid;
    if (farmerId == null) {
      return const Center(child: Text("Please login to view orders"));
    }
    return StreamBuilder<List<Order>>(
      stream: _firestoreService.streamFarmerOrders(farmerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data ?? [];
        final filtered = orders.where((order) {
          return _search.isEmpty ||
              order.id.toLowerCase().contains(_search.toLowerCase());
        }).toList();
        if (filtered.isEmpty) {
          return const Center(child: Text("No orders found"));
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return _orderTile(context, filtered[index]);
          },
        );
      },
    );
  }

  // 🧾 ORDER TILE
  Widget _orderTile(BuildContext context, Order order) {
    Color statusColor;
    switch (order.status) {
      case "Approved":
        statusColor = Colors.green;
        break;
      case "Delivered":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
        ),
        title: Text(
          "#${order.id.substring(0, 6).toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Customer: ${order.userId}\nAmount: ₹${order.total.toStringAsFixed(0)}",
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
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(order: order),
            ),
          );
        },
      ),
    );
  }
}
