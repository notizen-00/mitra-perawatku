import 'package:equatable/equatable.dart';

class AccountProfileUpdate extends Equatable {
  const AccountProfileUpdate({
    required this.specialization,
    required this.licenseNumber,
    required this.workLocation,
    required this.yearsOfExperience,
    required this.consultationFee,
    required this.bio,
    required this.isAvailable,
  });

  final String specialization;
  final String licenseNumber;
  final String workLocation;
  final int yearsOfExperience;
  final double consultationFee;
  final String bio;
  final bool isAvailable;

  Map<String, dynamic> toJson() {
    return {
      'specialization': specialization,
      'license_number': licenseNumber,
      'work_location': workLocation,
      'years_of_experience': yearsOfExperience,
      'consultation_fee': consultationFee,
      'bio': bio,
      'is_available': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
        specialization,
        licenseNumber,
        workLocation,
        yearsOfExperience,
        consultationFee,
        bio,
        isAvailable,
      ];
}
