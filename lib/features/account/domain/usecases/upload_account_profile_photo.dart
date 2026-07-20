import '../entities/account_summary.dart';
import '../repositories/account_repository.dart';

class UploadAccountProfilePhoto {
  const UploadAccountProfilePhoto(this._repository);

  final AccountRepository _repository;

  Future<AccountSummary> call(String filePath) {
    return _repository.uploadProfilePhoto(filePath);
  }
}
