import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum OrderStatus {
  pending,
  restaurantConfirmed,
  preparing,
  readyForPickup,
  completed,
  cancelled,
}

class Order {
  final String id;
  final String restaurantName;
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      restaurantName: data['restaurantName'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalPrice: data['totalPrice'] ?? 0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantName': restaurantName,
      'items': items,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isActive {
    return status == OrderStatus.pending ||
           status == OrderStatus.restaurantConfirmed ||
           status == OrderStatus.preparing ||
           status == OrderStatus.readyForPickup;
  }
}

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => [..._orders];
  List<Order> get activeOrders => _orders.where((order) => order.isActive).toList();
  List<Order> get completedOrders => _orders.where((order) => !order.isActive).toList();
  
  int get activeOrdersCount => activeOrders.length;
  bool get hasActiveOrder => activeOrders.isNotEmpty;
  bool get isLoading => _isLoading;

  // Load all user orders
  Future<void> loadOrders() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = querySnapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to real-time order updates
  Stream<List<Order>> ordersStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      notifyListeners();
      return _orders;
    });
  }

  // Create new order
  Future<String?> createOrder({
    required String restaurantName,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    try {
      final orderData = {
        'userId': uid,
        'restaurantName': restaurantName,
        'items': items,
        'totalPrice': totalPrice,
        'status': OrderStatus.pending.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('orders').add(orderData);
      
      // Reload orders to update the list
      await loadOrders();
      
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Update order status (for testing or restaurant side)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.toString().split('.').last,
      });

      // Update local order
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        await loadOrders(); // Reload to get updated data
      }
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.toString().split('.').last,
      });

      await loadOrders();
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  // Get specific order by ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
}