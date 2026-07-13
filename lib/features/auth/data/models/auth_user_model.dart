import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.phone,
    super.partnerProfile,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['partner_profile'];

    return AuthUserModel(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? '',
      partnerProfile: profile is Map<String, dynamic>
          ? PartnerProfileModel.fromJson(profile)
          : null,
    );
  }

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      partnerProfile: user.partnerProfile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      if (partnerProfile != null)
        'partner_profile': PartnerProfileModel.fromEntity(
          partnerProfile!,
        ).toJson(),
    };
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PartnerProfileModel extends PartnerProfile {
  const PartnerProfileModel({
    required super.profession,
    required super.verificationStatus,
    super.specialization,
    super.licenseNumber,
    super.workLocation,
    super.isAvailable,
  });

  factory PartnerProfileModel.fromJson(Map<String, dynamic> json) {
    return PartnerProfileModel(
      profession: json['profession']?.toString() ?? '',
      verificationStatus: json['verification_status']?.toString() ?? 'pending',
      specialization: json['specialization']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      workLocation: json['work_location']?.toString(),
      isAvailable: json['is_available'] == true,
    );
  }

  factory PartnerProfileModel.fromEntity(PartnerProfile profile) {
    return PartnerProfileModel(
      profession: profile.profession,
      verificationStatus: profile.verificationStatus,
      specialization: profile.specialization,
      licenseNumber: profile.licenseNumber,
      workLocation: profile.workLocation,
      isAvailable: profile.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profession': profession,
      'verification_status': verificationStatus,
      'specialization': specialization,
      'license_number': licenseNumber,
      'work_location': workLocation,
      'is_available': isAvailable,
    };
  }
}
