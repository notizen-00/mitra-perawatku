import '../entities/active_tracking.dart';

abstract class TrackingRepository {
  Future<ActiveTracking> getActiveTracking();
}
