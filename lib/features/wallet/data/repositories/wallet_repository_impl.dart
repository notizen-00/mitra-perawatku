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

      return WalletSummary(
        balance: _balance(bookings),
        todayIncome: bookings
            .where(_isToday)
            .where(_hasBalanceTransaction)
            .fold(0, (total, item) => total + _credit(item)),
        pendingIncome: bookings
            .where((item) => _paymentStatus(item) == 'paid')
            .where((item) => !_hasBalanceTransaction(item))
            .fold(0, (total, item) => total + asDouble(item['total_amount'])),
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
        .fold(0, (total, item) => total + _credit(item));
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
}
