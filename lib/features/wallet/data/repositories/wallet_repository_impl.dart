import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._apiClient, this._session);

  final ApiClient _apiClient;
  final AuthSession _session;

  @override
  Future<WalletSummary> getWalletSummary() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.serviceBookings,
        queryParameters: {
          'assigned_partner_user_id': _session.userId,
          'per_page': 50,
        },
      );
      final bookings = jsonList(response);
      final transactions = _transactions(bookings);

      return WalletSummary(
        balance: _balance(bookings),
        todayIncome: bookings
            .where(_isToday)
            .where(_hasBalanceTransaction)
            .fold(0.0, (total, item) => total + _credit(item)),
        pendingIncome: bookings
            .where((item) => _paymentStatus(item) == 'paid')
            .where((item) => !_hasBalanceTransaction(item))
            .fold(0.0, (total, item) => total + asDouble(item['total_amount'])),
        commissionIncome: transactions
            .where((item) => item.type == WalletTransactionType.commission)
            .fold(0.0, (total, item) => total + item.amount.abs()),
        bonusIncome: transactions
            .where((item) => item.type == WalletTransactionType.bonus)
            .fold(0.0, (total, item) => total + item.amount.abs()),
        transactions: transactions,
      );
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  double _balance(List<Map<String, dynamic>> bookings) {
    final balances = bookings
        .map((item) => jsonObject(item['partner_balance_transaction']))
        .whereType<Map<String, dynamic>>()
        .map((item) => asDouble(item['balance_after'] ?? item['balance']))
        .where((value) => value > 0)
        .toList();

    if (balances.isNotEmpty) return balances.first;

    return bookings
        .where(_hasBalanceTransaction)
        .fold(0.0, (total, item) => total + _credit(item));
  }

  double _credit(Map<String, dynamic> booking) {
    final transaction = jsonObject(booking['partner_balance_transaction']);
    if (transaction == null) return 0;
    return asDouble(
      transaction['amount'] ??
          transaction['credit'] ??
          transaction['total_amount'] ??
          booking['total_amount'],
    );
  }

  bool _hasBalanceTransaction(Map<String, dynamic> booking) {
    return booking['partner_balance_transaction'] is Map<String, dynamic>;
  }

  bool _isToday(Map<String, dynamic> booking) {
    final date = DateTime.tryParse(
      (booking['completed_at'] ?? booking['created_at'])?.toString() ?? '',
    )?.toLocal();
    final now = DateTime.now();
    return date != null &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _paymentStatus(Map<String, dynamic> booking) {
    return jsonObject(booking['payment'])?['status']?.toString() ?? 'unpaid';
  }

  List<WalletTransaction> _transactions(List<Map<String, dynamic>> bookings) {
    final transactions = <WalletTransaction>[];

    for (final booking in bookings) {
      final balanceTransaction = jsonObject(
        booking['partner_balance_transaction'],
      );

      if (balanceTransaction != null) {
        transactions.add(_balanceTransaction(booking, balanceTransaction));
        continue;
      }

      if (_paymentStatus(booking) == 'paid') {
        transactions.add(_pendingTransaction(booking));
      }
    }

    transactions.sort((a, b) => b.id.compareTo(a.id));
    return transactions.take(10).toList();
  }

  WalletTransaction _balanceTransaction(
    Map<String, dynamic> booking,
    Map<String, dynamic> transaction,
  ) {
    final amount = asDouble(
      transaction['amount'] ??
          transaction['credit'] ??
          transaction['debit'] ??
          transaction['total_amount'] ??
          booking['total_amount'],
    );
    final direction = transaction['direction']?.toString() ??
        transaction['type']?.toString() ??
        '';
    final signedAmount = _isDebit(direction, transaction) ? -amount.abs() : amount.abs();

    return WalletTransaction(
      id: asInt(transaction['id'] ?? booking['id']),
      title: _transactionTitle(booking, transaction),
      time: displayTime(
        transaction['created_at'] ??
            booking['completed_at'] ??
            booking['updated_at'] ??
            booking['created_at'],
      ),
      amount: signedAmount,
      status: _transactionStatus(transaction),
      type: _transactionType(booking, transaction),
    );
  }

  WalletTransaction _pendingTransaction(Map<String, dynamic> booking) {
    return WalletTransaction(
      id: asInt(booking['id']),
      title: _bookingTitle(booking),
      time: displayTime(
        booking['completed_at'] ?? booking['scheduled_at'] ?? booking['created_at'],
      ),
      amount: asDouble(booking['total_amount']),
      status: WalletTransactionStatus.inProgress,
      type: WalletTransactionType.service,
    );
  }

  WalletTransactionStatus _transactionStatus(Map<String, dynamic> transaction) {
    final status = transaction['status']?.toString().toLowerCase() ?? '';
    return switch (status) {
      'pending' => WalletTransactionStatus.pending,
      'processing' || 'in_progress' => WalletTransactionStatus.inProgress,
      _ => WalletTransactionStatus.completed,
    };
  }

  WalletTransactionType _transactionType(
    Map<String, dynamic> booking,
    Map<String, dynamic> transaction,
  ) {
    final raw = '${transaction['type'] ?? ''} ${transaction['category'] ?? ''}'
        .toLowerCase();
    if (raw.contains('withdraw')) return WalletTransactionType.withdrawal;
    if (raw.contains('bonus')) return WalletTransactionType.bonus;
    if (raw.contains('commission') || raw.contains('komisi')) {
      return WalletTransactionType.commission;
    }

    final serviceType =
        jsonObject(booking['service'])?['service_type']?.toString().toLowerCase() ??
            '';
    if (serviceType.contains('consult')) return WalletTransactionType.commission;

    return WalletTransactionType.service;
  }

  String _transactionTitle(
    Map<String, dynamic> booking,
    Map<String, dynamic> transaction,
  ) {
    final description = transaction['description']?.toString();
    if (description != null && description.trim().isNotEmpty) {
      return description;
    }

    return _bookingTitle(booking);
  }

  String _bookingTitle(Map<String, dynamic> booking) {
    final serviceName =
        jsonObject(booking['service'])?['name']?.toString() ?? 'Home Visit';
    final patientName =
        jsonObject(booking['patient_member'])?['name']?.toString() ??
            jsonObject(booking['patient'])?['name']?.toString() ??
            'Patient';

    return '$serviceName - $patientName';
  }

  bool _isDebit(String direction, Map<String, dynamic> transaction) {
    final raw = direction.toLowerCase();
    if (raw.contains('debit') ||
        raw.contains('withdraw') ||
        raw.contains('payout')) {
      return true;
    }

    return transaction['debit'] != null && asDouble(transaction['debit']) > 0;
  }
}
