import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/active_tracking.dart';
import '../../domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  const TrackingRepositoryImpl(this._apiClient, this._session);

  final ApiClient _apiClient;
  final AuthSession _session;

  @override
  Future<ActiveTracking> getActiveTracking() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.serviceBookings,
        queryParameters: {
          'assigned_partner_user_id': _session.userId,
          'per_page': 20,
        },
      );
      final active = jsonList(response).cast<Map<String, dynamic>?>().firstWhere(
        (item) => item != null && _isActive(item),
        orElse: () => null,
      );

      if (active == null) {
        return const ActiveTracking(
          id: 0,
          bookingCode: '-',
          title: 'Belum ada layanan aktif',
          patientName: 'Menunggu order baru',
          patientPhone: '-',
          status: 'idle',
          scheduledAt: '-',
          startedAt: '-',
          etaMinutes: 0,
          distanceKm: 0,
          totalAmount: 0,
          notes: '',
          addressLabel: '-',
          addressText: '-',
          paymentStatus: 'unpaid',
          histories: [],
        );
      }

      final detail = await _bookingDetail(active);
      return _tracking(detail);
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  Future<Map<String, dynamic>> _bookingDetail(Map<String, dynamic> booking) async {
    final id = asInt(booking['id']);
    if (id <= 0) return booking;

    try {
      final response = await _apiClient.get(ApiEndpoints.serviceBooking(id));
      return jsonObject(response['data']) ?? response;
    } on ApiException {
      return booking;
    }
  }

  ActiveTracking _tracking(Map<String, dynamic> booking) {
    final service = jsonObject(booking['service']);
    final patient = jsonObject(booking['patient']);
    final member = jsonObject(booking['patient_member']);
    final address = jsonObject(booking['address']);
    final payment = jsonObject(booking['payment']);
    final scheduledValue =
        booking['scheduled_at'] ?? booking['schedule_start_at'] ?? booking['created_at'];
    final startedValue = booking['started_at'] ?? booking['accepted_at'];
    final distance = _distanceKm(booking);

    return ActiveTracking(
      id: asInt(booking['id']),
      bookingCode: booking['booking_code']?.toString() ?? '-',
      title: service?['name']?.toString() ?? 'Layanan kesehatan',
      patientName:
          member?['name']?.toString() ?? patient?['name']?.toString() ?? 'Pasien',
      patientPhone:
          member?['phone']?.toString() ?? patient?['phone']?.toString() ?? '-',
      status: booking['status']?.toString() ?? 'pending',
      scheduledAt: displayTime(scheduledValue),
      startedAt: displayTime(startedValue),
      etaMinutes: _etaMinutes(booking, distance),
      distanceKm: distance,
      totalAmount: asDouble(booking['total_amount']),
      notes: booking['notes']?.toString() ?? '',
      addressLabel: address?['label']?.toString() ?? 'Alamat Pasien',
      addressText: address?['address']?.toString() ?? '-',
      paymentStatus: payment?['status']?.toString() ?? 'unpaid',
      histories: _histories(booking['histories']),
    );
  }

  double _distanceKm(Map<String, dynamic> booking) {
    final matchmaking = jsonObject(booking['matchmaking']);
    return asDouble(
      booking['distance_km'] ??
          matchmaking?['distance_km'] ??
          booking['distance'],
    );
  }

  int _etaMinutes(Map<String, dynamic> booking, double distance) {
    final eta = booking['eta_minutes'] ?? booking['estimated_arrival_minutes'];
    if (eta != null) return asInt(eta);
    if (distance <= 0) return 0;
    return (distance / 25 * 60).ceil();
  }

  List<TrackingHistory> _histories(Object? value) {
    if (value is! List) return const [];

    return value.whereType<Map<String, dynamic>>().map((item) {
      return TrackingHistory(
        title: item['title']?.toString() ?? '',
        status: item['status']?.toString() ?? '-',
        notes: item['notes']?.toString() ??
            item['description']?.toString() ??
            '',
        treatmentType: item['treatment_type']?.toString() ?? '',
        createdAt: displayTime(item['created_at'] ?? item['updated_at']),
      );
    }).toList();
  }

  bool _isActive(Map<String, dynamic> booking) {
    final status = booking['status']?.toString();
    return status == 'confirmed' ||
        status == 'scheduled' ||
        status == 'on_the_way';
  }
}
