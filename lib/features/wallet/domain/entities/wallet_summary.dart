import 'package:equatable/equatable.dart';

class WalletSummary extends Equatable {
  const WalletSummary({
    required this.balance,
    required this.todayIncome,
    required this.pendingIncome,
    required this.commissionIncome,
    required this.bonusIncome,
    required this.transactions,
  });

  final double balance;
  final double todayIncome;
  final double pendingIncome;
  final double commissionIncome;
  final double bonusIncome;
  final List<WalletTransaction> transactions;

  @override
  List<Object?> get props => [
    balance,
    todayIncome,
    pendingIncome,
    commissionIncome,
    bonusIncome,
    transactions,
  ];
}

class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.time,
    required this.amount,
    required this.status,
    required this.type,
  });

  final int id;
  final String title;
  final String time;
  final double amount;
  final WalletTransactionStatus status;
  final WalletTransactionType type;

  bool get isCredit => amount >= 0;

  @override
  List<Object?> get props => [id, title, time, amount, status, type];
}

enum WalletTransactionStatus { completed, inProgress, pending }

enum WalletTransactionType { service, withdrawal, commission, bonus }
