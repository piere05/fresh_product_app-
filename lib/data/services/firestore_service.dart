import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address.dart';
import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<List<Product>> streamProducts({
    String? category,
    String? search,
  }) {
    return _products.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map(Product.fromDoc)
              .where((product) {
                final matchesCategory =
                    category == null ||
                    category == 'All' ||
                    product.category == category;
                final matchesSearch = search == null ||
                    search.isEmpty ||
                    product.name
                        .toLowerCase()
                        .contains(search.toLowerCase());
                return matchesCategory && matchesSearch;
              })
              .toList(),
        );
  }

  Stream<List<Product>> streamFarmerProducts(String farmerId) {
    return _products
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Product.fromDoc).toList());
  }

  Future<void> addProduct(Product product) async {
    await _products.add(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  Stream<List<CartItem>> streamCart(String userId) {
    return _users
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CartItem.fromDoc).toList());
  }

  Future<void> addToCart({
    required String userId,
    required Product product,
    int quantity = 1,
  }) async {
    final doc = _users.doc(userId).collection('cart').doc(product.id);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (snapshot.exists) {
        final currentQty =
            (snapshot.data()?['quantity'] as num?)?.toInt() ?? 0;
        transaction.update(doc, {'quantity': currentQty + quantity});
      } else {
        transaction.set(doc, {
          'productId': product.id,
          'name': product.name,
          'price': product.price,
          'quantity': quantity,
          'unit': product.unit,
          'farmerId': product.farmerId,
        });
      }
    });
  }

  Future<void> updateCartItem({
    required String userId,
    required String cartItemId,
    required int quantity,
  }) async {
    final doc = _users.doc(userId).collection('cart').doc(cartItemId);
    if (quantity <= 0) {
      await doc.delete();
    } else {
      await doc.update({'quantity': quantity});
    }
  }

  Future<void> removeCartItem({
    required String userId,
    required String cartItemId,
  }) async {
    await _users.doc(userId).collection('cart').doc(cartItemId).delete();
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _users.doc(userId).collection('cart').get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<Address>> streamAddresses(String userId) {
    return _users
        .doc(userId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Address.fromDoc).toList());
  }

  Future<void> addAddress({
    required String userId,
    required Address address,
    bool makeDefault = false,
  }) async {
    final addressesRef = _users.doc(userId).collection('addresses');
    final snapshot = await addressesRef.get();
    final shouldDefault = makeDefault || snapshot.docs.isEmpty;
    final batch = _firestore.batch();
    if (shouldDefault) {
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    final docRef = addressesRef.doc();
    final payload = Map<String, dynamic>.from(address.toMap());
    payload['isDefault'] = shouldDefault;
    batch.set(docRef, payload);
    await batch.commit();
  }

  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    await _users.doc(userId).collection('addresses').doc(addressId).delete();
  }

  Future<void> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    final addressesRef = _users.doc(userId).collection('addresses');
    final snapshot = await addressesRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }
    await batch.commit();
  }

  Stream<List<WishlistItem>> streamWishlist(String userId) {
    return _users
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(WishlistItem.fromDoc).toList());
  }

  Future<void> addToWishlist({
    required String userId,
    required Product product,
  }) async {
    final doc = _users.doc(userId).collection('wishlist').doc(product.id);
    await doc.set(WishlistItem(
      id: product.id,
      productId: product.id,
      name: product.name,
      price: product.price,
      unit: product.unit,
      category: product.category,
      farmerId: product.farmerId,
    ).toMap());
  }

  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    await _users.doc(userId).collection('wishlist').doc(productId).delete();
  }

  Stream<List<AppUser>> streamFarmers({String? search}) {
    return _users
        .where('role', isEqualTo: 'farmer')
        .snapshots()
        .map((snapshot) {
      final farmers = snapshot.docs.map(AppUser.fromDoc).toList();
      if (search == null || search.isEmpty) {
        return farmers;
      }
      final query = search.toLowerCase();
      return farmers
          .where((farmer) => farmer.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> updateFarmerStatus({
    required String farmerId,
    required bool isApproved,
    required bool isBlocked,
  }) async {
    await _users.doc(farmerId).update({
      'isApproved': isApproved,
      'isBlocked': isBlocked,
    });
  }

  Future<void> createOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    required String paymentMethod,
  }) async {
    final orderItems = items
        .map(
          (item) => OrderItem(
            productId: item.productId,
            name: item.name,
            price: item.price,
            quantity: item.quantity,
            unit: item.unit,
            farmerId: item.farmerId,
          ),
        )
        .toList();
    await _orders.add(
      Order(
        id: '',
        userId: userId,
        items: orderItems,
        total: total,
        status: 'Pending',
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  Stream<List<Order>> streamOrders(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Order.fromDoc).toList());
  }
}
