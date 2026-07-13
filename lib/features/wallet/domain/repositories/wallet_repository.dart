import '../entities/wallet_summary.dart';

abstract class WalletRepository {
  Future<WalletSummary> getWalletSummary();
}
