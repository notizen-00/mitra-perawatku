import '../entities/mitra_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  const GetProfile(this.repository);

  final ProfileRepository repository;

  Future<MitraProfile> call() => repository.getProfile();
}
