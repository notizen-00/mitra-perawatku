import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/orders/domain/entities/incoming_order.dart';
import '../utils/json_helpers.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}

class FcmPushService {
  static const _androidChannel = AndroidNotificationChannel(
    'mitra_general_notifications',
    'Mitra Notifications',
    description: 'Notifikasi umum aplikasi Perawatku Mitra.',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _incomingOrders = StreamController<IncomingOrder>.broadcast();
  final _pendingOrders = <IncomingOrder>[];

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  final _tokenRefreshes = StreamController<String>.broadcast();
  FirebaseMessaging? _messaging;
  bool _initialized = false;
  bool _localNotificationsInitialized = false;

  Stream<IncomingOrder> get incomingOrders async* {
    for (final order in List<IncomingOrder>.from(_pendingOrders)) {
      yield order;
    }
    _pendingOrders.clear();
    yield* _incomingOrders.stream;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (error) {
      developer.log(
        'Firebase initializeApp gagal',
        name: 'token fcm',
        error: error,
      );
      return;
    }

    final messaging = FirebaseMessaging.instance;
    _messaging = messaging;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initializeLocalNotifications();

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log(
      'Notification permission: ${settings.authorizationStatus}',
      name: 'token fcm',
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      developer.log(
        'onMessage title=${message.notification?.title} body=${message.notification?.body} data=${message.data}',
        name: 'token fcm',
      );
      _handleMessage(message);
    });
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log(
        'onMessageOpenedApp title=${message.notification?.title} body=${message.notification?.body} data=${message.data}',
        name: 'token fcm',
      );
      _handleMessage(message);
    });
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) {
      developer.log('onTokenRefresh: $token', name: 'token fcm');
      _tokenRefreshes.add(token);
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      developer.log(
        'Initial FCM message title=${initialMessage.notification?.title} body=${initialMessage.notification?.body} data=${initialMessage.data}',
        name: 'token fcm',
      );
      _handleMessage(initialMessage);
    }

    _initialized = true;
  }

  Future<String?> getToken() async {
    final messaging = _messaging;
    if (messaging == null) return null;
    try {
      final token = await messaging.getToken();
      developer.log('getToken result: $token', name: 'token fcm');
      return token;
    } catch (error) {
      developer.log('getToken gagal', name: 'token fcm', error: error);
      return null;
    }
  }

  Stream<String> tokenRefreshes() {
    return _tokenRefreshes.stream;
  }

  void _handleMessage(RemoteMessage message) {
    final notification = _messageAsNotificationJson(message);
    if (!_isOrderNotification(notification)) {
      developer.log(
        'FCM diterima sebagai notifikasi umum: $notification',
        name: 'token fcm',
      );
      _showGeneralNotification(notification);
      return;
    }

    final booking = jsonObject(notification['booking']);
    final order = booking == null
        ? IncomingOrder.fromNotificationJson(notification)
        : IncomingOrder.fromBookingJson(booking);

    if (order.id <= 0) return;
    _emitIncomingOrder(order);
  }

  Map<String, dynamic> _messageAsNotificationJson(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final nestedData = _decodeObject(data['data']);
    final booking = _decodeObject(data['booking']);

    return {
      'id': data['id'] ?? data['notification_id'],
      'type': data['type'] ?? message.messageType,
      'title': data['title'] ?? message.notification?.title,
      'body': data['body'] ?? message.notification?.body,
      'reference_id':
          data['reference_id'] ?? data['service_booking_id'] ?? data['booking_id'],
      'reference_type': data['reference_type'],
      if (booking != null) 'booking': booking,
      'data': {
        ...data,
        if (nestedData != null) ...nestedData,
      },
    };
  }

  bool _isOrderNotification(Map<String, dynamic> notification) {
    final data = jsonObject(notification['data']);
    final type = notification['type']?.toString() ?? data?['type']?.toString();
    final referenceType = notification['reference_type']?.toString();

    return notification['booking'] is Map<String, dynamic> ||
        referenceType == 'service_booking' ||
        type == 'service_booking.matched' ||
        type == 'service_booking.paid' ||
        type == 'service_booking.status_updated' ||
        data?['service_booking_id'] != null ||
        data?['booking_id'] != null;
  }

  Map<String, dynamic>? _decodeObject(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is! String || value.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      return null;
    }

    return null;
  }

  void _emitIncomingOrder(IncomingOrder order) {
    if (_incomingOrders.hasListener) {
      _incomingOrders.add(order);
      return;
    }

    _pendingOrders.add(order);
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _localNotifications.initialize(initializationSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _localNotificationsInitialized = true;
  }

  Future<void> _showGeneralNotification(
    Map<String, dynamic> notification,
  ) async {
    await _initializeLocalNotifications();

    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    final title = notification['title']?.toString() ?? 'Perawatku Mitra';
    final body = notification['body']?.toString() ?? 'Notifikasi baru';

    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mitra_general_notifications',
          'Mitra Notifications',
          channelDescription: 'Notifikasi umum aplikasi Perawatku Mitra.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshes.close();
    _incomingOrders.close();
  }
}
