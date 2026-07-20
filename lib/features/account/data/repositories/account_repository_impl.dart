import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../models/account_summary_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._remoteDataSource, this._session);

  final AccountRemoteDataSource _remoteDataSource;
  final AuthSession _session;

  @override
  Future<AccountSummary> getAccount() async {
    try {
      final responses = await Future.wait([
        _remoteDataSource.getMe(),
        _remoteDataSource.getServiceApplications(),
      ]);

      return AccountSummaryModel.fromApi(
        meResponse: responses[0],
        servicesResponse: responses[1],
      );
    } on ApiException catch (error) {
      throw _mapApiException(error);
    } on FormatException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } on ApiException {
      // Local session still has to be cleared so the user exits the app safely.
    } finally {
      await _session.clear();
    }
  }

  Failure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      0 => NetworkFailure(error.message),
      401 || 403 => UnauthorizedFailure(error.message),
      _ => ServerFailure(error.message),
    };
  }
}
