import '../entities/wallet_summary.dart';
import '../repositories/wallet_repository.dart';

class GetWalletSummary {
  const GetWalletSummary(this.repository);

  final WalletRepository repository;

  Future<WalletSummary> call() => repository.getWalletSummary();
}
