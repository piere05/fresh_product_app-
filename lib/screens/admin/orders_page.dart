// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'order_details_page.dart';
import '../../data/models/order.dart';
import '../../data/services/firestore_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key}); // NOT const

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _search = '';
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // 🏷 STATUS FILTER (UI ONLY)
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _StatusChip(
                  label: "All",
                  color: Colors.grey,
                  selected: _statusFilter == 'All',
                  onTap: () => setState(() => _statusFilter = 'All'),
                ),
                _StatusChip(
                  label: "Pending",
                  color: Colors.orange,
                  selected: _statusFilter == 'Pending',
                  onTap: () => setState(() => _statusFilter = 'Pending'),
                ),
                _StatusChip(
                  label: "Approved",
                  color: Colors.green,
                  selected: _statusFilter == 'Approved',
                  onTap: () => setState(() => _statusFilter = 'Approved'),
                ),
                _StatusChip(
                  label: "Delivered",
                  color: Colors.blue,
                  selected: _statusFilter == 'Delivered',
                  onTap: () => setState(() => _statusFilter = 'Delivered'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📋 ORDERS LIST
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: _firestoreService.streamAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data ?? [];
                final filtered = orders.where((order) {
                  final matchesStatus =
                      _statusFilter == 'All' || order.status == _statusFilter;
                  final matchesSearch = _search.isEmpty ||
                      order.id.toLowerCase().contains(_search.toLowerCase());
                  return matchesStatus && matchesSearch;
                }).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _orderCard(context, filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ORDER CARD
  Widget _orderCard(BuildContext context, Order order) {
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

// STATUS CHIP (UI ONLY)
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: color.withOpacity(0.2),
        backgroundColor: color.withOpacity(0.1),
        labelStyle: TextStyle(color: color),
      ),
    );
  }
}
