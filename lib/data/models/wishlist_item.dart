import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.category,
    this.farmerId,
  });

  final String id;
  final String productId;
  final String name;
  final double price;
  final String unit;
  final String category;
  final String? farmerId;

  factory WishlistItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WishlistItem(
      id: doc.id,
      productId: (data['productId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      unit: (data['unit'] as String?) ?? 'kg',
      category: (data['category'] as String?) ?? 'Others',
      farmerId: data['farmerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'unit': unit,
      'category': category,
      'farmerId': farmerId,
    };
  }
}
