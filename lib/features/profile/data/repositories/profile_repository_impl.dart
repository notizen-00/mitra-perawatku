import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/mitra_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<MitraProfile> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      final user = jsonObject(response['data']) ?? response;
      final profile = jsonObject(user['partner_profile']);

      return MitraProfile(
        name: user['name']?.toString() ?? 'Mitra',
        email: user['email']?.toString() ?? '-',
        phone: user['phone']?.toString() ?? '-',
        profession: profile?['profession']?.toString() ?? '-',
        verificationStatus: profile?['verification_status']?.toString() ?? '-',
        workLocation: profile?['work_location']?.toString() ?? '-',
      );
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.mitraProfile,
        body: {'is_available': isAvailable},
      );
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }
}
