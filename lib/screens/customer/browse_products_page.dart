import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details_page.dart';
import '../../data/models/product.dart';
import '../../data/services/firestore_service.dart';

class BrowseProductsPage extends StatefulWidget {
  const BrowseProductsPage({super.key});

  @override
  State<BrowseProductsPage> createState() => _BrowseProductsPageState();
}

class _BrowseProductsPageState extends State<BrowseProductsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  String _search = "";
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text("Browse Products"),
        backgroundColor: Colors.blue,
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
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷 CATEGORY FILTER
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _categoryChip("All"),
                _categoryChip("Vegetables"),
                _categoryChip("Fruits"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🛒 PRODUCT LIST
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _firestoreService.streamProducts(
                category: _selectedCategory,
                search: _search,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _productCard(context, products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🏷 CATEGORY CHIP
  Widget _categoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.blue),
        onSelected: (_) {
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  // 🧾 PRODUCT CARD
  Widget _productCard(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 🖼 IMAGE PLACEHOLDER
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.shopping_bag, color: Colors.blue),
              ),

              const SizedBox(width: 12),

              // 📦 PRODUCT INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Category: ${product.category}"),
                    Text(
                      "₹${product.price.toStringAsFixed(0)} / ${product.unit}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // 🛒 ADD TO CART
              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                color: Colors.blue,
                onPressed: () async {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please login to add items to cart"),
                      ),
                    );
                    return;
                  }
                  await _firestoreService.addToCart(
                    userId: userId,
                    product: product,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${product.name} added to cart"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
