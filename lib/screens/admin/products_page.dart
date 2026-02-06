import 'package:flutter/material.dart';
import 'add_product_page.dart';
import '../../data/models/product.dart';
import '../../data/services/firestore_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),

      // ADD PRODUCT
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductPage()),
          );
        },
      ),

      body: Column(
        children: [
          // SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: "Search products...",
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

          // LIST
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _firestoreService.streamProducts(search: _search),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _productCard(
                      product: product,
                      onEdit: () => _editProduct(product),
                      onDelete: () => _deleteProduct(product.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // PRODUCT CARD
  Widget _productCard({
    required Product product,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final bool inStock = product.inStock;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.shopping_bag, color: Colors.orange),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Category: ${product.category}\n"
          "Price: ₹${product.price.toStringAsFixed(0)} / ${product.unit}",
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              inStock ? "In Stock" : "Out of Stock",
              style: TextStyle(
                color: inStock ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✏️ EDIT PRODUCT (REAL)
  void _editProduct(Product product) {
    final nameCtrl = TextEditingController(text: product.name);
    final categoryCtrl = TextEditingController(text: product.category);
    final priceCtrl = TextEditingController(text: product.price.toString());
    String stock = product.inStock ? "In Stock" : "Out of Stock";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Product"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Product Name"),
              ),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: stock,
                items: const [
                  DropdownMenuItem(value: "In Stock", child: Text("In Stock")),
                  DropdownMenuItem(
                    value: "Out of Stock",
                    child: Text("Out of Stock"),
                  ),
                ],
                onChanged: (value) => stock = value!,
                decoration: const InputDecoration(labelText: "Stock Status"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.updateProduct(
                productId: product.id,
                updates: {
                  'name': nameCtrl.text.trim(),
                  'category': categoryCtrl.text.trim(),
                  'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
                  'inStock': stock == "In Stock",
                },
              );
              if (!mounted) {
                return;
              }
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  // 🗑 DELETE PRODUCT
  void _deleteProduct(String productId) {
    _firestoreService.deleteProduct(productId);
  }
}
