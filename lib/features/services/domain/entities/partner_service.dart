import 'package:equatable/equatable.dart';

class PartnerService extends Equatable {
  const PartnerService({
    required this.id,
    required this.name,
    required this.radiusKm,
    required this.isActive,
    required this.isVerified,
  });

  final int id;
  final String name;
  final int radiusKm;
  final bool isActive;
  final bool isVerified;

  @override
  List<Object?> get props => [id, name, radiusKm, isActive, isVerified];
}
