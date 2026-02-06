import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    this.farmerId,
  });

  final String id;
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final String? farmerId;

  double get total => price * quantity;

  factory CartItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CartItem(
      id: doc.id,
      productId: (data['productId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: (data['unit'] as String?) ?? 'kg',
      farmerId: data['farmerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'farmerId': farmerId,
    };
  }
}
