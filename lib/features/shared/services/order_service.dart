import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'order_model.dart' show Order, OrderStatus;

// ── OrderService ──────────────────────────────────────────────────────────────
// All Firestore order operations live here.
// CartProvider calls placeOrder(). Restaurant screen calls updateStatus().

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _orders => _firestore.collection('orders');

  // ── Place order ───────────────────────────────────────────────────────────
  // Called by CartProvider on checkout.
  // Returns the new order's Firestore document ID on success.

  Future<String> placeOrder({
    required String restaurantId,
    required String restaurantName,
    required List<Map<String, dynamic>> items,  // serialized CartItems
    required int total,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final docRef = await _orders.add({
      'customerId': user.uid,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items,
      'total': total,
      'status': OrderStatus.pending.firestoreValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // ── Update order status (restaurant side) ─────────────────────────────────

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    await _orders.doc(orderId).update({
      'status': newStatus.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Listen to a single order (customer order tracking) ───────────────────

  Stream<Order> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Order not found');
      return Order.fromDoc(doc);
    });
  }

  // ── Listen to just order status (safer for tracking UI) ──────────────────

  Stream<OrderStatus> watchOrderStatus(String orderId) {
    return _orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Order not found');
      final data = doc.data() as Map<String, dynamic>?;
      return OrderStatus.fromFirestore(data?['status'] ?? data?['orderStatus']);
    });
  }

  // ── Get all orders for current user ──────────────────────────────────────

  Stream<List<Order>> watchUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _orders
        .where('customerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Order.fromDoc(doc)).toList());
  }

  // ── Get all orders for a restaurant (restaurant dashboard) ───────────────

  Stream<List<Order>> watchRestaurantOrders(String restaurantId) {
    return _orders
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Order.fromDoc(doc)).toList());
  }

  // ── Get active orders only (pending + confirmed + preparing) ─────────────

  Stream<List<Order>> watchActiveRestaurantOrders(String restaurantId) {
    return watchRestaurantOrders(restaurantId).map((orders) => orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.restaurantConfirmed ||
            o.status == OrderStatus.preparing)
        .toList());
  }
}