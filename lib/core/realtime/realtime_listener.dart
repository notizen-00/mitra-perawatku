import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../../features/orders/domain/entities/incoming_order.dart';
import '../../features/orders/domain/usecases/accept_service_booking.dart';
import '../../features/orders/domain/usecases/decline_service_booking.dart';
import '../../features/orders/presentation/widgets/incoming_order_dialog.dart';
import '../utils/json_helpers.dart';
import '../router/app_router.dart';
import '../services/fcm_push_service.dart';
import '../services/reverb_websocket_service.dart';

class RealtimeListener extends StatefulWidget {
  const RealtimeListener({required this.child, super.key});

  final Widget child;

  @override
  State<RealtimeListener> createState() => _RealtimeListenerState();
}

class _RealtimeListenerState extends State<RealtimeListener> {
  StreamSubscription<ReverbEvent>? _subscription;
  StreamSubscription<IncomingOrder>? _fcmSubscription;
  bool _dialogOpen = false;

  late final AcceptServiceBooking _accept = sl<AcceptServiceBooking>();
  late final DeclineServiceBooking _decline = sl<DeclineServiceBooking>();

  @override
  void initState() {
    super.initState();
    _subscription = sl<ReverbWebSocketService>().events.listen(_onEvent);
    _fcmSubscription = sl<FcmPushService>().incomingOrders.listen(
      _showIncomingOrder,
    );
  }

  void _onEvent(ReverbEvent event) {
    if (event.name == 'service-booking.matched') {
      _handleMatched(event);
      return;
    }

    if (event.name == 'notification.created') {
      _handleNotification(event);
    }
  }

  void _handleMatched(ReverbEvent event) {
    final booking = jsonObject(event.dataAsMap['booking']);
    if (booking == null) return;

    final order = IncomingOrder.fromBookingJson(booking);
    _showIncomingOrder(order);
  }

  void _handleNotification(ReverbEvent event) {
    final referenceType = event.dataAsMap['reference_type']?.toString();
    final data = jsonObject(event.dataAsMap['data']);
    final type = event.dataAsMap['type']?.toString() ?? data?['type']?.toString();
    final isOrderNotification =
        referenceType == 'service_booking' ||
        type == 'service_booking.matched' ||
        data?['service_booking_id'] != null;

    if (!isOrderNotification) return;

    final order = IncomingOrder.fromNotificationJson(event.dataAsMap);
    if (order.id <= 0) return;
    _showIncomingOrder(order);
  }

  void _showIncomingOrder(IncomingOrder order) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    SystemSound.play(SystemSoundType.alert);

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _dialogOpen = false;
      return;
    }

    showIncomingOrderDialog(
      context: context,
      order: order,
      onAccept: () => _accept(order.id),
      onDecline: () => _decline(order.id),
    ).then((accepted) {
      _dialogOpen = false;
      if (accepted == true) {
        rootNavigatorKey.currentContext?.go('/orders/${order.id}');
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
