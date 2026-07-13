import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.partnerProfile,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final PartnerProfile? partnerProfile;

  @override
  List<Object?> get props => [id, name, email, role, phone, partnerProfile];
}

class PartnerProfile extends Equatable {
  const PartnerProfile({
    required this.profession,
    required this.verificationStatus,
    this.specialization,
    this.licenseNumber,
    this.workLocation,
    this.isAvailable = false,
  });

  final String profession;
  final String verificationStatus;
  final String? specialization;
  final String? licenseNumber;
  final String? workLocation;
  final bool isAvailable;

  @override
  List<Object?> get props => [
    profession,
    verificationStatus,
    specialization,
    licenseNumber,
    workLocation,
    isAvailable,
  ];
}
