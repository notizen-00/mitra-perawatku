import '../../../../core/config/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_result_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResultModel> login({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    final response = await _apiClient.post(
      _loginEndpoint(role),
      body: {'email': email, 'password': password},
    );

    return AuthResultModel.fromJson(response);
  }

  Future<AuthResultModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String profession,
    required String specialization,
    required String licenseNumber,
    String? workLocation,
    int? yearsOfExperience,
    double? consultationFee,
    String? bio,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.mitraRegister,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'profession': profession,
        'specialization': specialization,
        'license_number': licenseNumber,
        if (workLocation != null && workLocation.isNotEmpty)
          'work_location': workLocation,
        if (yearsOfExperience != null)
          'years_of_experience': yearsOfExperience,
        if (consultationFee != null) 'consultation_fee': consultationFee,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
      },
    );

    return AuthResultModel.fromJson(response);
  }

  String _loginEndpoint(LoginRole role) {
    return switch (role) {
      LoginRole.general => ApiEndpoints.mitraLogin,
      LoginRole.doctor => ApiEndpoints.doctorLogin,
      LoginRole.nurse => ApiEndpoints.nurseLogin,
      LoginRole.pharmacy => ApiEndpoints.pharmacyLogin,
    };
  }
}
