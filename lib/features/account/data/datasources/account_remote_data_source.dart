import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

class AccountRemoteDataSource {
  const AccountRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getMe() {
    return _apiClient.get(ApiEndpoints.me);
  }

  Future<Map<String, dynamic>> getServiceApplications() {
    return _apiClient.get(
      ApiEndpoints.serviceApplications,
      queryParameters: {'per_page': 50},
    );
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}
