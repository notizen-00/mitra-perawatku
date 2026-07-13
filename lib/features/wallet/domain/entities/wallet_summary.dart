import 'package:equatable/equatable.dart';

class WalletSummary extends Equatable {
  const WalletSummary({
    required this.balance,
    required this.todayIncome,
    required this.pendingIncome,
  });

  final double balance;
  final double todayIncome;
  final double pendingIncome;

  @override
  List<Object?> get props => [balance, todayIncome, pendingIncome];
}
