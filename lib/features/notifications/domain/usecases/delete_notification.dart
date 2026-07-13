import '../repositories/notifications_repository.dart';

class DeleteNotification {
  const DeleteNotification(this.repository);

  final NotificationsRepository repository;

  Future<void> call(int id) => repository.deleteNotification(id);
}
