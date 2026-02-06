import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/product.dart';
import '../../data/services/firestore_service.dart';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  String _search = "";
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text("Stock Management"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() => _search = value);
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📦 STOCK LIST
          Expanded(
            child: _buildStockList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Please login to manage stock"));
    }

    return StreamBuilder<List<Product>>(
      stream: _firestoreService.streamFarmerProducts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data ?? [];
        final filteredStock = products.where((item) {
          return item.name.toLowerCase().contains(_search.toLowerCase());
        }).toList();
        if (filteredStock.isEmpty) {
          return const Center(
            child: Text(
              "No products found",
              style: TextStyle(fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          itemCount: filteredStock.length,
          itemBuilder: (context, index) {
            final item = filteredStock[index];
            final int qty = item.quantity.toInt();
            final bool lowStock = qty <= 10;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: lowStock
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  child: Icon(
                    Icons.inventory,
                    color: lowStock ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Quantity: $qty ${item.unit}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lowStock ? "Low Stock" : "Available",
                      style: TextStyle(
                        color: lowStock ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.orange,
                          ),
                          onPressed: () async {
                            final nextQty = qty > 0 ? qty - 1 : 0;
                            await _firestoreService.updateProduct(
                              productId: item.id,
                              updates: {'quantity': nextQty},
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await _firestoreService.updateProduct(
                              productId: item.id,
                              updates: {'quantity': qty + 1},
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
