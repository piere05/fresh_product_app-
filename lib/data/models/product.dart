import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.farmerId,
    this.description,
    this.imageUrl,
    this.inStock = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final double quantity;
  final String farmerId;
  final String? description;
  final String? imageUrl;
  final bool inStock;
  final DateTime? createdAt;

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Product(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'Others',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      unit: (data['unit'] as String?) ?? 'kg',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
      farmerId: (data['farmerId'] as String?) ?? '',
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      inStock: (data['inStock'] as bool?) ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'farmerId': farmerId,
      'description': description,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
