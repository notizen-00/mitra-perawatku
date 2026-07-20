import '../repositories/account_repository.dart';

class LogoutAccount {
  const LogoutAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call() {
    return _repository.logout();
  }
}
