import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    this.farmerId,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final String? farmerId;

  double get total => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
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

class Order {
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.createdAt,
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String paymentMethod;
  final DateTime? createdAt;

  factory Order.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final itemsData = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    return Order(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      items: itemsData.map(OrderItem.fromMap).toList(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: (data['status'] as String?) ?? 'Pending',
      paymentMethod: (data['paymentMethod'] as String?) ?? 'COD',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
