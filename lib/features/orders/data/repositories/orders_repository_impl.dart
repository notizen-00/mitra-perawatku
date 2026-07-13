import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/order_booking.dart';
import '../../domain/entities/order_detail.dart';
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

    final scheduledValue =
        json['scheduled_at'] ?? json['schedule_start_at'] ?? json['created_at'];

    return OrderBooking(
      id: asInt(json['id']),
      code: json['booking_code']?.toString() ?? '-',
      serviceName: service?['name']?.toString() ?? 'Layanan',
      patientName:
          patient?['name']?.toString() ?? member?['name']?.toString() ?? 'Pasien',
      status: json['status']?.toString() ?? 'pending',
      scheduledDate: _displayDate(scheduledValue),
      scheduledAt: displayTime(scheduledValue),
      totalAmount: asDouble(json['total_amount']),
    );
  }

  @override
  Future<OrderDetail> getOrderDetail(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.serviceBooking(id));
      return _detail(jsonObject(response['data']) ?? response);
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<OrderDetail> acceptServiceBooking(int id) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.acceptServiceBooking(id),
        body: {'notes': ''},
      );
      return _detail(jsonObject(response['data']) ?? response);
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<OrderDetail> declineServiceBooking(int id) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.serviceBookingStatus(id),
        body: {'status': 'cancelled', 'notes': ''},
      );
      return _detail(jsonObject(response['data']) ?? response);
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  String _displayDate(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '-';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  OrderDetail _detail(Map<String, dynamic> json) {
    final service = jsonObject(json['service']);
    final patient = jsonObject(json['patient']);
    final member = jsonObject(json['patient_member']);
    final address = jsonObject(json['address']);
    final payment = jsonObject(json['payment']);
    final scheduledValue =
        json['scheduled_at'] ?? json['schedule_start_at'] ?? json['created_at'];
    final startedValue = json['started_at'] ?? json['accepted_at'];
    final distance = _distanceKm(json);

    return OrderDetail(
      id: asInt(json['id']),
      code: json['booking_code']?.toString() ?? '-',
      serviceName: service?['name']?.toString() ?? 'Layanan kesehatan',
      patientName:
          member?['name']?.toString() ?? patient?['name']?.toString() ?? 'Pasien',
      patientPhone:
          member?['phone']?.toString() ?? patient?['phone']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'pending',
      scheduledAt: displayTime(scheduledValue),
      startedAt: displayTime(startedValue),
      totalAmount: asDouble(json['total_amount']),
      notes: json['notes']?.toString() ?? '',
      addressLabel: address?['label']?.toString() ?? 'Alamat Pasien',
      addressText: address?['address']?.toString() ?? '-',
      distanceKm: distance,
      etaMinutes: _etaMinutes(json, distance),
      paymentStatus: payment?['status']?.toString() ?? 'unpaid',
      histories: _histories(json['histories']),
    );
  }

  double _distanceKm(Map<String, dynamic> json) {
    final matchmaking = jsonObject(json['matchmaking']);
    return asDouble(
      json['distance_km'] ?? matchmaking?['distance_km'] ?? json['distance'],
    );
  }

  int _etaMinutes(Map<String, dynamic> json, double distance) {
    final eta = json['eta_minutes'] ?? json['estimated_arrival_minutes'];
    if (eta != null) return asInt(eta);
    if (distance <= 0) return 0;
    return (distance / 25 * 60).ceil();
  }

  List<OrderHistory> _histories(Object? value) {
    if (value is! List) return const [];

    return value.whereType<Map<String, dynamic>>().map((item) {
      return OrderHistory(
        status: item['status']?.toString() ?? '-',
        notes: item['notes']?.toString() ?? '',
        createdAt: displayTime(item['created_at'] ?? item['updated_at']),
      );
    }).toList();
  }
}
