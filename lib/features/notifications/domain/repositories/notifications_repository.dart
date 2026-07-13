import '../entities/notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();

  Future<void> markAsRead(int id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int id);
}
