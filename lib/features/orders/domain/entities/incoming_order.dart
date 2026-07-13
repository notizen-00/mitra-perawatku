import '../../../../core/utils/json_helpers.dart';

class IncomingOrder {
  const IncomingOrder({
    required this.id,
    required this.code,
    required this.serviceName,
    required this.patientName,
    required this.scheduledAt,
    required this.totalAmount,
    required this.paymentStatus,
    required this.addressLabel,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
  });

  final int id;
  final String code;
  final String serviceName;
  final String patientName;
  final String scheduledAt;
  final double totalAmount;
  final String paymentStatus;
  final String addressLabel;
  final String addressText;
  final double latitude;
  final double longitude;
  final double distanceKm;

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  factory IncomingOrder.fromBookingJson(Map<String, dynamic> json) {
    final service = jsonObject(json['service']);
    final patient = jsonObject(json['patient']);
    final member = jsonObject(json['patient_member']);
    final payment = jsonObject(json['payment']);
    final address = jsonObject(json['address']);
    final matchmaking = jsonObject(json['matchmaking']);
    final scheduled =
        json['scheduled_at'] ?? json['schedule_start_at'] ?? json['created_at'];

    return IncomingOrder(
      id: asInt(json['id']),
      code: json['booking_code']?.toString() ?? '-',
      serviceName: service?['name']?.toString() ?? 'Layanan kesehatan',
      patientName:
          member?['name']?.toString() ??
          patient?['name']?.toString() ??
          'Pasien',
      scheduledAt: displayTime(scheduled),
      totalAmount: asDouble(json['total_amount']),
      paymentStatus: payment?['status']?.toString() ?? 'unpaid',
      addressLabel: address?['label']?.toString() ?? 'Alamat Pasien',
      addressText: address?['address']?.toString() ?? '-',
      latitude: asDouble(address?['latitude']),
      longitude: asDouble(address?['longitude']),
      distanceKm: asDouble(
        json['distance_km'] ?? matchmaking?['distance_km'] ?? json['distance'],
      ),
    );
  }

  factory IncomingOrder.fromNotificationJson(Map<String, dynamic> json) {
    final data = jsonObject(json['data']);
    return IncomingOrder(
      id: asInt(
        data?['service_booking_id'] ??
            data?['booking_id'] ??
            json['reference_id'] ??
            json['id'],
      ),
      code: data?['booking_code']?.toString() ?? '-',
      serviceName: data?['service_name']?.toString() ?? 'Layanan kesehatan',
      patientName: data?['patient_name']?.toString() ?? 'Pasien',
      scheduledAt: data?['scheduled_at']?.toString() ?? '-',
      totalAmount: asDouble(data?['total_amount']),
      paymentStatus: data?['payment_status']?.toString() ?? 'unpaid',
      addressLabel: data?['address_label']?.toString() ?? 'Alamat Pasien',
      addressText: data?['address']?.toString() ?? '-',
      latitude: asDouble(data?['latitude']),
      longitude: asDouble(data?['longitude']),
      distanceKm: asDouble(data?['distance_km']),
    );
  }
}
