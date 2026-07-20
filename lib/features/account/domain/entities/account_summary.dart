import 'package:equatable/equatable.dart';

class AccountSummary extends Equatable {
  const AccountSummary({
    required this.name,
    required this.email,
    required this.phone,
    required this.profession,
    required this.specialization,
    required this.licenseNumber,
    required this.workLocation,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.isAvailable,
    required this.verificationStatus,
    required this.joinedYear,
    required this.hasStrDocument,
    required this.hasKtpDocument,
    required this.totalServices,
    required this.activeServices,
    required this.verifiedServices,
  });

  final String name;
  final String email;
  final String phone;
  final String profession;
  final String specialization;
  final String licenseNumber;
  final String workLocation;
  final int yearsOfExperience;
  final double consultationFee;
  final bool isAvailable;
  final String verificationStatus;
  final String joinedYear;
  final bool hasStrDocument;
  final bool hasKtpDocument;
  final int totalServices;
  final int activeServices;
  final int verifiedServices;

  bool get isVerified => verificationStatus.toLowerCase() == 'verified';

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        profession,
        specialization,
        licenseNumber,
        workLocation,
        yearsOfExperience,
        consultationFee,
        isAvailable,
        verificationStatus,
        joinedYear,
        hasStrDocument,
        hasKtpDocument,
        totalServices,
        activeServices,
        verifiedServices,
      ];
}
