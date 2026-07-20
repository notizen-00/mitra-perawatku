import '../entities/account_summary.dart';
import '../repositories/account_repository.dart';

class GetAccount {
  const GetAccount(this._repository);

  final AccountRepository _repository;

  Future<AccountSummary> call() {
    return _repository.getAccount();
  }
}
