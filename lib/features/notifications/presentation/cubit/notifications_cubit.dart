import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/delete_notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_all_notifications_read.dart';
import '../../domain/usecases/mark_notification_read.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required GetNotifications getNotifications,
    required MarkNotificationRead markAsRead,
    required MarkAllNotificationsRead markAllAsRead,
    required DeleteNotification deleteNotification,
  }) : super(const NotificationsInitial()) {
    _getNotifications = getNotifications;
    _markAsRead = markAsRead;
    _markAllAsRead = markAllAsRead;
    _deleteNotification = deleteNotification;
  }

  late final GetNotifications _getNotifications;
  late final MarkNotificationRead _markAsRead;
  late final MarkAllNotificationsRead _markAllAsRead;
  late final DeleteNotification _deleteNotification;

  Future<void> load() async {
    if (state is! NotificationsLoaded) {
      emit(const NotificationsLoading());
    }

    try {
      emit(NotificationsLoaded(await _getNotifications()));
    } on Failure catch (error) {
      emit(NotificationsError(error.message));
    } catch (_) {
      emit(const NotificationsError('Notifikasi belum bisa dimuat.'));
    }
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    if (state is! NotificationsLoaded) return;

    final current = state as NotificationsLoaded;
    final updated = current.notifications.map((item) {
      return item.id == notification.id
          ? AppNotification(
              id: item.id,
              userId: item.userId,
              type: item.type,
              title: item.title,
              body: item.body,
              actionUrl: item.actionUrl,
              referenceType: item.referenceType,
              referenceId: item.referenceId,
              data: item.data,
              readAt: DateTime.now(),
              createdAt: item.createdAt,
            )
          : item;
    }).toList();

    emit(NotificationsLoaded(updated));

    try {
      await _markAsRead(notification.id);
    } on Failure {
      // Keep optimistic update; list will refresh on next load.
    }
  }

  Future<void> markAllAsRead() async {
    if (state is! NotificationsLoaded) return;

    final current = state as NotificationsLoaded;
    if (current.notifications.every((item) => item.isRead)) return;

    final updated = current.notifications.map((item) {
      return item.isRead
          ? item
          : AppNotification(
              id: item.id,
              userId: item.userId,
              type: item.type,
              title: item.title,
              body: item.body,
              actionUrl: item.actionUrl,
              referenceType: item.referenceType,
              referenceId: item.referenceId,
              data: item.data,
              readAt: DateTime.now(),
              createdAt: item.createdAt,
            );
    }).toList();

    emit(NotificationsLoaded(updated));

    try {
      await _markAllAsRead();
    } on Failure {
      // Keep optimistic update; list will refresh on next load.
    }
  }

  Future<void> delete(int id) async {
    if (state is! NotificationsLoaded) return;

    final current = state as NotificationsLoaded;
    final updated =
        current.notifications.where((item) => item.id != id).toList();

    emit(NotificationsLoaded(updated));

    try {
      await _deleteNotification(id);
    } on Failure {
      // Keep optimistic update; list will refresh on next load.
    }
  }
}
