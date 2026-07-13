import 'package:equatable/equatable.dart';

class OrderBooking extends Equatable {
  const OrderBooking({
    required this.id,
    required this.code,
    required this.serviceName,
    required this.patientName,
    required this.status,
    required this.scheduledAt,
    required this.totalAmount,
  });

  final int id;
  final String code;
  final String serviceName;
  final String patientName;
  final String status;
  final String scheduledAt;
  final double totalAmount;

  @override
  List<Object?> get props => [
    id,
    code,
    serviceName,
    patientName,
    status,
    scheduledAt,
    totalAmount,
  ];
}
