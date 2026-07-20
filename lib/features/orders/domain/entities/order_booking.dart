import 'package:equatable/equatable.dart';

class OrderBooking extends Equatable {
  const OrderBooking({
    required this.id,
    required this.code,
    required this.serviceName,
    required this.patientName,
    required this.status,
    required this.scheduledDate,
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
  final String status;
  final String scheduledDate;
  final String scheduledAt;
  final double totalAmount;
  final String paymentStatus;
  final String addressLabel;
  final String addressText;
  final double latitude;
  final double longitude;
  final double distanceKm;

  @override
  List<Object?> get props => [
    id,
    code,
    serviceName,
    patientName,
    status,
    scheduledDate,
    scheduledAt,
    totalAmount,
    paymentStatus,
    addressLabel,
    addressText,
    latitude,
    longitude,
    distanceKm,
  ];
}
