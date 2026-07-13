import '../entities/notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  const GetNotifications(this.repository);

  final NotificationsRepository repository;

  Future<List<AppNotification>> call() => repository.getNotifications();
}
