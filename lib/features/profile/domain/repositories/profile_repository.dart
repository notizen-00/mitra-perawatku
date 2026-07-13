import '../entities/mitra_profile.dart';

abstract class ProfileRepository {
  Future<MitraProfile> getProfile();
}
