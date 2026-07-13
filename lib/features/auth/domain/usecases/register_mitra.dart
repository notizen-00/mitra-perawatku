import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterMitra {
  const RegisterMitra(this.repository);

  final AuthRepository repository;

  Future<AuthResult> call({
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
  }) {
    return repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      profession: profession,
      specialization: specialization,
      licenseNumber: licenseNumber,
      workLocation: workLocation,
      yearsOfExperience: yearsOfExperience,
      consultationFee: consultationFee,
      bio: bio,
    );
  }
}
