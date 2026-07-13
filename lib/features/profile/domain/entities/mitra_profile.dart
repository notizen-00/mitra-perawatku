import 'package:equatable/equatable.dart';

class MitraProfile extends Equatable {
  const MitraProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.profession,
    required this.verificationStatus,
    required this.workLocation,
  });

  final String name;
  final String email;
  final String phone;
  final String profession;
  final String verificationStatus;
  final String workLocation;

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    profession,
    verificationStatus,
    workLocation,
  ];
}
