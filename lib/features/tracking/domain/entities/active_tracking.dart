import 'package:equatable/equatable.dart';

class ActiveTracking extends Equatable {
  const ActiveTracking({
    required this.title,
    required this.patientName,
    required this.status,
    required this.etaMinutes,
    required this.distanceKm,
  });

  final String title;
  final String patientName;
  final String status;
  final int etaMinutes;
  final double distanceKm;

  bool get hasActiveService => status != 'idle';

  @override
  List<Object?> get props => [
    title,
    patientName,
    status,
    etaMinutes,
    distanceKm,
  ];
}
