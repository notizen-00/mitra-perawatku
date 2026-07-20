import '../entities/account_summary.dart';
import '../repositories/account_repository.dart';

class DeleteAccountProfilePhoto {
  const DeleteAccountProfilePhoto(this._repository);

  final AccountRepository _repository;

  Future<AccountSummary> call() {
    return _repository.deleteProfilePhoto();
  }
}
