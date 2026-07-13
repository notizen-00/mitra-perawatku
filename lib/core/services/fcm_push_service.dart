import 'dart:async';

import '../../features/orders/domain/entities/incoming_order.dart';

class FcmPushService {
  final _incomingOrders = StreamController<IncomingOrder>.broadcast();

  Stream<IncomingOrder> get incomingOrders => _incomingOrders.stream;

  Future<void> initialize() async {}

  Future<String?> getToken() async => null;

  Stream<String> tokenRefreshes() => const Stream.empty();

  void dispose() {
    _incomingOrders.close();
  }
}
