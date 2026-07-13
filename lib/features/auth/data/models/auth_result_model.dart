import '../../domain/entities/auth_result.dart';
import 'auth_user_model.dart';

class AuthResultModel extends AuthResult {
  const AuthResultModel({required super.user, required super.token});

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    final user = json['data'];
    final token = json['user_api_token'] ?? json['token'];

    if (user is! Map<String, dynamic>) {
      throw const FormatException('Data user tidak ditemukan pada respons.');
    }

    if (token is! String || token.isEmpty) {
      throw const FormatException('Token login tidak ditemukan pada respons.');
    }

    return AuthResultModel(
      user: AuthUserModel.fromJson(user),
      token: token,
    );
  }
}
