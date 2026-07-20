import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/account_summary.dart';

class AccountSummaryModel extends AccountSummary {
  const AccountSummaryModel({
    required super.name,
    required super.email,
    required super.phone,
    required super.profession,
    required super.specialization,
    required super.licenseNumber,
    required super.workLocation,
    required super.yearsOfExperience,
    required super.consultationFee,
    required super.isAvailable,
    required super.verificationStatus,
    required super.joinedYear,
    required super.hasStrDocument,
    required super.hasKtpDocument,
    required super.totalServices,
    required super.activeServices,
    required super.verifiedServices,
  });

  factory AccountSummaryModel.fromApi({
    required Map<String, dynamic> meResponse,
    required Map<String, dynamic> servicesResponse,
  }) {
    final user = jsonObject(meResponse['data']) ?? meResponse;
    final profile = jsonObject(user['partner_profile']) ?? <String, dynamic>{};
    final services = jsonList(servicesResponse);
    final createdAt = DateTime.tryParse(user['created_at']?.toString() ?? '');

    return AccountSummaryModel(
      name: user['name']?.toString() ?? 'Mitra',
      email: user['email']?.toString() ?? '-',
      phone: user['phone']?.toString() ?? '-',
      profession: profile['profession']?.toString() ?? '-',
      specialization: profile['specialization']?.toString() ?? '-',
      licenseNumber: profile['license_number']?.toString() ?? '-',
      workLocation: profile['work_location']?.toString() ?? '-',
      yearsOfExperience: asInt(profile['years_of_experience']),
      consultationFee: asDouble(profile['consultation_fee']),
      isAvailable: profile['is_available'] == true,
      verificationStatus:
          profile['verification_status']?.toString() ?? 'pending',
      joinedYear: createdAt?.year.toString() ?? '-',
      hasStrDocument:
          (profile['str_photo_path']?.toString().trim().isNotEmpty ?? false),
      hasKtpDocument:
          (profile['ktp_photo_path']?.toString().trim().isNotEmpty ?? false),
      totalServices: services.length,
      activeServices:
          services.where((item) => item['is_active'] == true).length,
      verifiedServices:
          services.where((item) => item['is_verified'] == true).length,
    );
  }
}
