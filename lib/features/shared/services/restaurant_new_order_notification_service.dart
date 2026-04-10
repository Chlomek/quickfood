import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RestaurantNewOrderNotificationService {
  RestaurantNewOrderNotificationService._();

  static final RestaurantNewOrderNotificationService instance =
      RestaurantNewOrderNotificationService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSubscription;
  bool _hasLoadedInitialSnapshot = false;

  static const AndroidNotificationChannel _restaurantOrderChannel =
      AndroidNotificationChannel(
        'restaurant_new_orders',
        'Restaurant new orders',
        description: 'Notifications when a new order appears for restaurant',
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
        ?.createNotificationChannel(_restaurantOrderChannel);

    _authSubscription ??= _auth.authStateChanges().listen((user) {
      _onAuthChanged(user);
    });

    await _onAuthChanged(_auth.currentUser);
  }

  Future<void> dispose() async {
    await _ordersSubscription?.cancel();
    await _authSubscription?.cancel();
    _ordersSubscription = null;
    _authSubscription = null;
    _hasLoadedInitialSnapshot = false;
  }

  Future<void> _onAuthChanged(User? user) async {
    await _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _hasLoadedInitialSnapshot = false;

    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();
    final role = userData?['role'];

    if (role != 'restaurant') {
      return;
    }

    final restaurantId = await _resolveRestaurantId(user.uid, userData);
    if (restaurantId == null) {
      return;
    }

    _ordersSubscription = _firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .listen(_handleOrderSnapshot);
  }

  Future<String?> _resolveRestaurantId(
    String uid,
    Map<String, dynamic>? userData,
  ) async {
    final directId = userData?['restaurantId'];
    if (directId is String && directId.isNotEmpty) return directId;

    final restaurantIds = userData?['restaurantIds'];
    if (restaurantIds is List && restaurantIds.isNotEmpty) {
      final first = restaurantIds.first;
      if (first is String && first.isNotEmpty) return first;
    }

    final ownedRestaurant = await _firestore
        .collection('restaurants')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (ownedRestaurant.docs.isNotEmpty) {
      return ownedRestaurant.docs.first.id;
    }

    return null;
  }

  void _handleOrderSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (!_hasLoadedInitialSnapshot) {
      _hasLoadedInitialSnapshot = true;
      return;
    }

    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;

      final data = change.doc.data();
      if (data == null) continue;

      final total = data['total'];
      final parsedTotal = total is num ? total.toInt() : 0;

      final itemList = data['items'];
      int itemCount = 0;
      if (itemList is List) {
        itemCount = itemList.length;
      }

      _showNewOrderNotification(
        orderId: change.doc.id,
        total: parsedTotal,
        itemCount: itemCount,
      );
    }
  }

  Future<void> _showNewOrderNotification({
    required String orderId,
    required int total,
    required int itemCount,
  }) async {
    final title = 'New order received';
    final body =
        'Order #${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length)}: $itemCount items, total $total CZK';

    await _notifications.show(
      orderId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'restaurant_new_orders',
          'Restaurant new orders',
          channelDescription:
              'Notifications when a new order appears for restaurant',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
