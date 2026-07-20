import '../entities/account_profile_update.dart';
import '../entities/account_summary.dart';
import '../repositories/account_repository.dart';

class UpdateAccountProfile {
  const UpdateAccountProfile(this._repository);

  final AccountRepository _repository;

  Future<AccountSummary> call(AccountProfileUpdate input) {
    return _repository.updateProfile(input);
  }
}
