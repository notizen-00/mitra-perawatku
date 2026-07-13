import 'package:equatable/equatable.dart';

class OrderDetail extends Equatable {
  const OrderDetail({
    required this.id,
    required this.code,
    required this.serviceName,
    required this.patientName,
    required this.patientPhone,
    required this.status,
    required this.scheduledAt,
    required this.startedAt,
    required this.totalAmount,
    required this.notes,
    required this.addressLabel,
    required this.addressText,
    required this.distanceKm,
    required this.etaMinutes,
    required this.paymentStatus,
    required this.histories,
  });

  final int id;
  final String code;
  final String serviceName;
  final String patientName;
  final String patientPhone;
  final String status;
  final String scheduledAt;
  final String startedAt;
  final double totalAmount;
  final String notes;
  final String addressLabel;
  final String addressText;
  final double distanceKm;
  final int etaMinutes;
  final String paymentStatus;
  final List<OrderHistory> histories;

  @override
  List<Object?> get props => [
    id,
    code,
    serviceName,
    patientName,
    patientPhone,
    status,
    scheduledAt,
    startedAt,
    totalAmount,
    notes,
    addressLabel,
    addressText,
    distanceKm,
    etaMinutes,
    paymentStatus,
    histories,
  ];
}

class OrderHistory extends Equatable {
  const OrderHistory({
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  final String status;
  final String notes;
  final String createdAt;

  @override
  List<Object?> get props => [status, notes, createdAt];
}
