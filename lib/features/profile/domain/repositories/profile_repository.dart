import '../entities/mitra_profile.dart';

abstract class ProfileRepository {
  Future<MitraProfile> getProfile();

  Future<void> updateAvailability(bool isAvailable);
}
