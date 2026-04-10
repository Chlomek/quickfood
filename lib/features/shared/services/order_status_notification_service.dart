import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'order_model.dart' show OrderStatus;

class OrderStatusNotificationService {
  OrderStatusNotificationService._();

  static final OrderStatusNotificationService instance =
      OrderStatusNotificationService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  final Map<String, OrderStatus> _lastKnownStatuses = <String, OrderStatus>{};

  static const AndroidNotificationChannel _statusChannel =
      AndroidNotificationChannel(
        'order_status_updates',
        'Order status updates',
        description: 'Notifications when an order status changes',
        importance: Importance.high,
      );

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_statusChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _authSubscription ??= _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> dispose() async {
    await _ordersSubscription?.cancel();
    await _authSubscription?.cancel();
    _ordersSubscription = null;
    _authSubscription = null;
    _lastKnownStatuses.clear();
  }

  void _onAuthChanged(User? user) {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _lastKnownStatuses.clear();

    if (user == null) {
      return;
    }

    _ordersSubscription = _firestore
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .snapshots()
        .listen(_handleOrderSnapshot);
  }

  void _handleOrderSnapshot(QuerySnapshot snapshot) {
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;

      final nextStatus = OrderStatus.fromFirestore(
        data['status'] ?? data['orderStatus'],
      );
      final previousStatus = _lastKnownStatuses[doc.id];

      _lastKnownStatuses[doc.id] = nextStatus;

      if (previousStatus == null || previousStatus == nextStatus) {
        continue;
      }

      final restaurantName = (data['restaurantName'] as String?)?.trim();
      final safeRestaurantName =
          (restaurantName == null || restaurantName.isEmpty)
          ? 'Restaurant'
          : restaurantName;

      _showStatusChangedNotification(
        orderId: doc.id,
        restaurantName: safeRestaurantName,
        status: nextStatus,
      );
    }
  }

  Future<void> _showStatusChangedNotification({
    required String orderId,
    required String restaurantName,
    required OrderStatus status,
  }) async {
    final title = 'Order update';
    final body =
        'Your order from $restaurantName is now ${_statusLabel(status)}.';

    await _notifications.show(
      orderId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_status_updates',
          'Order status updates',
          channelDescription: 'Notifications when an order status changes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.restaurantConfirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'being prepared';
      case OrderStatus.ready:
        return 'ready for pickup';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}
