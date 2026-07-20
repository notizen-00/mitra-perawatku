import '../entities/account_summary.dart';

abstract class AccountRepository {
  Future<AccountSummary> getAccount();

  Future<void> logout();
}
