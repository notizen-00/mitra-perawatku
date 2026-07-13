import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginMitra {
  const LoginMitra(this.repository);

  final AuthRepository repository;

  Future<AuthResult> call({
    required String email,
    required String password,
    required LoginRole role,
  }) {
    return repository.login(email: email, password: password, role: role);
  }
}
