import '../config/api_endpoints.dart';
import '../network/api_client.dart';

class PartnerLocationSyncService {
  const PartnerLocationSyncService(this._apiClient);

  final ApiClient _apiClient;

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
}
