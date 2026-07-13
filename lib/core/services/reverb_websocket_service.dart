import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import '../config/api_endpoints.dart';
import '../network/api_client.dart';
import 'auth_session.dart';

class ReverbWebSocketService {
  ReverbWebSocketService(this._apiClient, this._session);

  final ApiClient _apiClient;
  final AuthSession _session;
  final StreamController<ReverbEvent> _events =
      StreamController<ReverbEvent>.broadcast();
  final Set<String> _subscribedChannels = {};

  WebSocket? _socket;
  String? _socketId;

  Stream<ReverbEvent> get events => _events.stream;
  bool get isConnected => _socket?.readyState == WebSocket.open;
  String? get socketId => _socketId;

  Future<void> connect() async {
    if (isConnected) return;

    _socket = await WebSocket.connect(ApiConfig.reverbUri.toString());
    _socket!.listen(
      _handleRawMessage,
      onError: _handleError,
      onDone: _handleDone,
      cancelOnError: true,
    );
  }

  Future<void> subscribePartnerBookings({int? partnerUserId}) async {
    final id = partnerUserId ?? _session.userId;
    if (id == null) return;

    await subscribePrivateChannel('private-partner.$id.service-bookings');
  }

  Future<void> subscribeUserNotifications({int? userId}) async {
    final id = userId ?? _session.userId;
    if (id == null) return;

    await subscribePrivateChannel('private-user.$id.notifications');
  }

  Future<void> subscribeConsultation(int consultationId) async {
    await subscribePrivateChannel('private-consultation.$consultationId');
  }

  Future<void> subscribePrivateChannel(String channelName) async {
    await connect();

    if (_socketId == null) {
      await events.firstWhere(
        (event) => event.name == 'pusher:connection_established',
      );
    }

    if (_subscribedChannels.contains(channelName)) return;

    final authResponse = await _apiClient.post(
      ApiEndpoints.broadcastingAuth,
      body: {'socket_id': _socketId, 'channel_name': channelName},
    );

    final payload = <String, dynamic>{
      'channel': channelName,
      'auth': authResponse['auth'],
      if (authResponse['channel_data'] != null)
        'channel_data': authResponse['channel_data'],
    };

    _send('pusher:subscribe', payload);
    _subscribedChannels.add(channelName);
  }

  Future<void> unsubscribe(String channelName) async {
    if (!isConnected) return;

    _send('pusher:unsubscribe', {'channel': channelName});
    _subscribedChannels.remove(channelName);
  }

  Future<void> disconnect() async {
    _subscribedChannels.clear();
    _socketId = null;
    await _socket?.close();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _events.close();
  }

  void _handleRawMessage(dynamic raw) {
    if (raw is! String) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    final event = ReverbEvent.fromJson(decoded);

    if (event.name == 'pusher:connection_established') {
      final data = event.dataAsMap;
      _socketId = data['socket_id']?.toString();
    }

    if (event.name == 'pusher:ping') {
      _send('pusher:pong', const {});
      return;
    }

    _events.add(event);
  }

  void _handleError(Object error) {
    _events.add(
      ReverbEvent(
        name: 'connection.error',
        channel: null,
        data: {'message': error.toString()},
      ),
    );
  }

  void _handleDone() {
    _subscribedChannels.clear();
    _socketId = null;
    _socket = null;
  }

  void _send(String event, Map<String, dynamic> data) {
    if (!isConnected) return;

    _socket!.add(jsonEncode({'event': event, 'data': data}));
  }
}

class ReverbEvent {
  const ReverbEvent({
    required this.name,
    required this.channel,
    required this.data,
  });

  factory ReverbEvent.fromJson(Map<String, dynamic> json) {
    return ReverbEvent(
      name: json['event']?.toString() ?? '',
      channel: json['channel']?.toString(),
      data: _decodeData(json['data']),
    );
  }

  final String name;
  final String? channel;
  final Object? data;

  Map<String, dynamic> get dataAsMap {
    final value = data;
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  static Object? _decodeData(Object? value) {
    if (value is String && value.isNotEmpty) {
      final decoded = jsonDecode(value);
      return decoded;
    }

    return value;
  }
}
