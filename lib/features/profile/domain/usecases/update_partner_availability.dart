import '../repositories/profile_repository.dart';

class UpdatePartnerAvailability {
  const UpdatePartnerAvailability(this.repository);

  final ProfileRepository repository;

  Future<void> call(bool isAvailable) =>
      repository.updateAvailability(isAvailable);
}
