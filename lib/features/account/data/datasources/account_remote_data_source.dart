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

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) {
    return _apiClient.patch(ApiEndpoints.mitraProfile, body: body);
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) {
    return _apiClient.postMultipartFile(
      path: ApiEndpoints.profilePhoto,
      fieldName: 'profile_photo',
      filePath: filePath,
    );
  }

  Future<Map<String, dynamic>> deleteProfilePhoto() {
    return _apiClient.delete(ApiEndpoints.profilePhoto);
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}
