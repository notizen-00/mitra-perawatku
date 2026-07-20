import '../entities/account_summary.dart';
import '../entities/account_profile_update.dart';

abstract class AccountRepository {
  Future<AccountSummary> getAccount();

  Future<AccountSummary> updateProfile(AccountProfileUpdate input);

  Future<AccountSummary> uploadProfilePhoto(String filePath);

  Future<AccountSummary> deleteProfilePhoto();

  Future<void> logout();
}
