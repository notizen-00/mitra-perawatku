import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
    required LoginRole role,
  });

  Future<AuthResult> register({
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
  });
}

enum LoginRole { general, doctor, nurse, pharmacy }
