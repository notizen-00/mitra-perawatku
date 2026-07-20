import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import '../config/api_endpoints.dart';
import '../network/api_client.dart';
import 'auth_session.dart';

enum ReverbConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class ReverbWebSocketService {
  ReverbWebSocketService(this._apiClient, this._session);

  final ApiClient _apiClient;
  final AuthSession _session;
  final StreamController<ReverbEvent> _events =
      StreamController<ReverbEvent>.broadcast();
  final StreamController<ReverbConnectionState> _connectionState =
      StreamController<ReverbConnectionState>.broadcast();
  final Set<String> _desiredChannels = {};
  final Set<String> _subscribedChannels = {};

  WebSocket? _socket;
  String? _socketId;
  ReverbConnectionState _state = ReverbConnectionState.disconnected;
  bool _disposed = false;
  bool _intentionalClose = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  Stream<ReverbEvent> get events => _events.stream;
  Stream<ReverbConnectionState> get connectionState =>
      _connectionState.stream;
  ReverbConnectionState get state => _state;
  bool get isConnected => _socket?.readyState == WebSocket.open;
  String? get socketId => _socketId;

  void _setState(ReverbConnectionState next) {
    if (_state == next) return;
    _state = next;
    if (!_connectionState.isClosed) _connectionState.add(next);
  }

  /// Connects the socket and subscribes to the channels this mitra needs
  /// for notifications and realtime booking/order events.
  Future<void> connectAndSubscribe() async {
    if (!_session.isAuthenticated) return;

    try {
      await connect();
      final userId = _session.userId;
      if (userId != null) {
        await subscribePartnerBookings();
        await subscribeUserNotifications();
      }
    } catch (_) {
      // Connection state already reflects the failure; auto-reconnect retries.
    }
  }

  Future<void> connect() async {
    if (_state == ReverbConnectionState.connected ||
        _state == ReverbConnectionState.connecting) {
      return;
    }

    _reconnectTimer?.cancel();
    _intentionalClose = false;
    _setState(ReverbConnectionState.connecting);

    try {
      _socket = await WebSocket.connect(ApiConfig.reverbUri.toString());
      _socket!.listen(
        _handleRawMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: true,
      );
    } catch (error) {
      _setState(ReverbConnectionState.error);
      _events.add(
        ReverbEvent(
          name: 'connection.error',
          channel: null,
          data: {'message': error.toString()},
        ),
      );
      _scheduleReconnect();
    }
  }

  Future<void> subscribePartnerBookings({int? partnerUserId}) async {
    final id = partnerUserId ?? _session.userId;
    if (id == null) return;

    await _subscribe('private-partner.$id.service-bookings');
  }

  Future<void> subscribeUserNotifications({int? userId}) async {
    final id = userId ?? _session.userId;
    if (id == null) return;

    await _subscribe('private-user.$id.notifications');
  }

  Future<void> subscribeConsultation(int consultationId) async {
    await _subscribe('private-consultation.$consultationId');
  }

  Future<void> _subscribe(String channelName) async {
    await connect();

    if (_socketId == null) {
      await events.firstWhere(
        (event) => event.name == 'pusher:connection_established',
      );
    }

    if (_subscribedChannels.contains(channelName)) return;

    _desiredChannels.add(channelName);
    await _authenticateAndSubscribe(channelName);
  }

  Future<void> _authenticateAndSubscribe(String channelName) async {
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

  void _resubscribeAll() {
    for (final channel in _desiredChannels) {
      _authenticateAndSubscribe(channel);
    }
  }

  Future<void> unsubscribe(String channelName) async {
    if (!isConnected) return;

    _send('pusher:unsubscribe', {'channel': channelName});
    _subscribedChannels.remove(channelName);
    _desiredChannels.remove(channelName);
  }

  Future<void> disconnect() async {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _desiredChannels.clear();
    _subscribedChannels.clear();
    _socketId = null;
    await _socket?.close();
    _socket = null;
    _setState(ReverbConnectionState.disconnected);
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    disconnect();
    _events.close();
    _connectionState.close();
  }

  void _scheduleReconnect() {
    if (_disposed || !_session.isAuthenticated) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectAttempts++;
    final seconds = (_reconnectAttempts * 2).clamp(2, 10);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      if (_disposed || !_session.isAuthenticated) return;
      connectAndSubscribe();
    });
  }

  void _handleRawMessage(dynamic raw) {
    if (raw is! String) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    final event = ReverbEvent.fromJson(decoded);

    if (event.name == 'pusher:connection_established') {
      final data = event.dataAsMap;
      _socketId = data['socket_id']?.toString();
      _reconnectAttempts = 0;
      _setState(ReverbConnectionState.connected);
      _resubscribeAll();
    }

    if (event.name == 'pusher:ping') {
      _send('pusher:pong', const {});
      return;
    }

    _events.add(event);
  }

  void _handleError(Object error) {
    if (_state != ReverbConnectionState.error) {
      _setState(ReverbConnectionState.error);
    }
    _events.add(
      ReverbEvent(
        name: 'connection.error',
        channel: null,
        data: {'message': error.toString()},
      ),
    );
    _scheduleReconnect();
  }

  void _handleDone() {
    _subscribedChannels.clear();
    _socketId = null;
    _socket = null;

    if (_intentionalClose) {
      _setState(ReverbConnectionState.disconnected);
      return;
    }

    _setState(ReverbConnectionState.disconnected);
    _scheduleReconnect();
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
