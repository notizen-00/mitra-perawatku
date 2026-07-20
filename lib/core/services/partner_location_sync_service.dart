import 'dart:async';
import 'dart:developer' as developer;

import 'package:geolocator/geolocator.dart';

import '../config/api_endpoints.dart';
import '../network/api_client.dart';

class PartnerLocationSyncService {
  PartnerLocationSyncService(this._apiClient);

  final ApiClient _apiClient;
  StreamSubscription<Position>? _positionSubscription;
  int? _activeBookingId;
  DateTime? _lastSentAt;

  Future<void> sendCurrentLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.mitraProfile,
      body: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<void> sendBookingLocation({
    required int bookingId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    double? heading,
    double? speedMps,
    DateTime? recordedAt,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.serviceBookingLocation(bookingId),
      body: {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
        if (heading != null) 'heading': heading,
        if (speedMps != null) 'speed_mps': speedMps,
        if (recordedAt != null) 'recorded_at': _backendDateTime(recordedAt),
      },
    );
  }

  Future<void> startBookingLocationSync(int bookingId) async {
    if (bookingId <= 0 || _activeBookingId == bookingId) return;

    await stopBookingLocationSync();

    try {
      final permissionReady = await _ensurePermission();
      if (!permissionReady) {
        developer.log(
          'Lokasi booking tidak dimulai: izin lokasi belum tersedia',
          name: 'partner_location',
        );
        return;
      }

      _activeBookingId = bookingId;
      _lastSentAt = null;

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _sendPosition(bookingId, current, force: true);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (position) => _sendPosition(bookingId, position),
        onError: (Object error, StackTrace stackTrace) {
          developer.log(
            'Stream lokasi booking error',
            name: 'partner_location',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );
    } catch (error, stackTrace) {
      developer.log(
        'Lokasi booking belum bisa dikirim',
        name: 'partner_location',
        error: error,
        stackTrace: stackTrace,
      );
      await stopBookingLocationSync(bookingId: bookingId);
    }
  }

  Future<void> stopBookingLocationSync({int? bookingId}) async {
    if (bookingId != null && _activeBookingId != bookingId) return;

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _activeBookingId = null;
    _lastSentAt = null;
  }

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _sendPosition(
    int bookingId,
    Position position, {
    bool force = false,
  }) async {
    final now = DateTime.now();
    if (!force &&
        _lastSentAt != null &&
        now.difference(_lastSentAt!) < const Duration(seconds: 5)) {
      return;
    }

    _lastSentAt = now;
    try {
      await sendBookingLocation(
        bookingId: bookingId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        heading: position.heading,
        speedMps: position.speed,
        recordedAt: position.timestamp,
      );
      developer.log(
        'Lokasi booking terkirim untuk booking_id=$bookingId',
        name: 'partner_location',
      );
    } catch (error, stackTrace) {
      developer.log(
        'Gagal kirim lokasi booking_id=$bookingId',
        name: 'partner_location',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _backendDateTime(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }
}
