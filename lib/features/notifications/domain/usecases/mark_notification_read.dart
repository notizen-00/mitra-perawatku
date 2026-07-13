import '../repositories/notifications_repository.dart';

class MarkNotificationRead {
  const MarkNotificationRead(this.repository);

  final NotificationsRepository repository;

  Future<void> call(int id) => repository.markAsRead(id);
}
