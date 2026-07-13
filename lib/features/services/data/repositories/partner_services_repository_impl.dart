import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/partner_service.dart';
import '../../domain/repositories/partner_services_repository.dart';

class PartnerServicesRepositoryImpl implements PartnerServicesRepository {
  const PartnerServicesRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<PartnerService>> getServices() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.serviceApplications,
        queryParameters: {'per_page': 50},
      );
      return jsonList(response).map(_service).toList();
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  PartnerService _service(Map<String, dynamic> json) {
    final service = jsonObject(json['service']);
    return PartnerService(
      id: asInt(json['id']),
      name: service?['name']?.toString() ?? 'Layanan',
      radiusKm: asInt(json['coverage_radius_km']),
      isActive: json['is_active'] == true,
      isVerified: json['is_verified'] == true,
    );
  }
}
