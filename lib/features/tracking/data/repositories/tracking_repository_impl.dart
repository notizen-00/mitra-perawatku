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
          title: 'Belum ada layanan aktif',
          patientName: 'Menunggu order baru',
          status: 'idle',
          etaMinutes: 0,
          distanceKm: 0,
        );
      }

      final service = jsonObject(active['service']);
      final patient = jsonObject(active['patient']);
      final distance = asDouble(active['distance_km'] ?? active['distance']);

      return ActiveTracking(
        title: service?['name']?.toString() ?? 'Layanan kesehatan',
        patientName: patient?['name']?.toString() ?? 'Pasien',
        status: active['status']?.toString() ?? 'pending',
        etaMinutes: distance <= 0 ? 0 : (distance / 25 * 60).ceil(),
        distanceKm: distance,
      );
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  bool _isActive(Map<String, dynamic> booking) {
    final status = booking['status']?.toString();
    return status == 'confirmed' ||
        status == 'scheduled' ||
        status == 'on_the_way';
  }
}
