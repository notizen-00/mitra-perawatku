import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/order_booking.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._apiClient, this._session);

  final ApiClient _apiClient;
  final AuthSession _session;

  @override
  Future<List<OrderBooking>> getOrders() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.serviceBookings,
        queryParameters: {
          'assigned_partner_user_id': _session.userId,
          'per_page': 50,
        },
      );

      return jsonList(response).map(_booking).toList();
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  OrderBooking _booking(Map<String, dynamic> json) {
    final service = jsonObject(json['service']);
    final patient = jsonObject(json['patient']);
    final member = jsonObject(json['patient_member']);

    return OrderBooking(
      id: asInt(json['id']),
      code: json['booking_code']?.toString() ?? '-',
      serviceName: service?['name']?.toString() ?? 'Layanan',
      patientName:
          patient?['name']?.toString() ?? member?['name']?.toString() ?? 'Pasien',
      status: json['status']?.toString() ?? 'pending',
      scheduledAt: displayTime(
        json['scheduled_at'] ?? json['schedule_start_at'] ?? json['created_at'],
      ),
      totalAmount: asDouble(json['total_amount']),
    );
  }
}
