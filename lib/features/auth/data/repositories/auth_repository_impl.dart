import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._session);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSession _session;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
        role: role,
      );
      await _session.save(
        token: result.token,
        userId: result.user.id,
        user: result.user,
      );
      return result;
    } on ApiException catch (error) {
      throw _mapApiException(error);
    } on FormatException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
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
  }) async {
    try {
      final result = await _remoteDataSource.register(
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
      await _session.save(
        token: result.token,
        userId: result.user.id,
        user: result.user,
      );
      return result;
    } on ApiException catch (error) {
      throw _mapApiException(error);
    } on FormatException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  Failure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      0 => NetworkFailure(error.message),
      401 || 403 => UnauthorizedFailure(error.message),
      422 => ValidationFailure(error.message),
      _ => ServerFailure(error.message),
    };
  }
}
