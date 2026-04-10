import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class FcmPushNotificationService {
  FcmPushNotificationService._();

  static final FcmPushNotificationService instance =
      FcmPushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  static const AndroidNotificationChannel _pushChannel =
      AndroidNotificationChannel(
    'push_notifications',
    'Push notifications',
    description: 'General push notifications',
    importance: Importance.high,
  );

  /// Initializes Firebase Messaging, notification permissions and listeners.
  Future<void> initialize() async {
    await _initializeLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );

    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen((token) {
      _saveTokenForCurrentUser(token);
    });

    _authSubscription ??= _auth.authStateChanges().listen((user) async {
      if (user == null) return;
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveTokenForCurrentUser(token);
      }
    });

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveTokenForCurrentUser(token);
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_pushChannel);
  }

  Future<void> _saveTokenForCurrentUser(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? (message.data['title'] as String?);
    final body = message.notification?.body ?? (message.data['body'] as String?);

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title ?? 'QuickFood',
      body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'push_notifications',
          'Push notifications',
          channelDescription: 'General push notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Disposes subscriptions if needed (for tests/shutdown).
  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    _authSubscription = null;
    _tokenRefreshSubscription = null;
    _foregroundMessageSubscription = null;
  }
}
