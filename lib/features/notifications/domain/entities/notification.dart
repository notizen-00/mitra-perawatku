import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.actionUrl,
    required this.referenceType,
    required this.referenceId,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String type;
  final String title;
  final String body;
  final String? actionUrl;
  final String? referenceType;
  final int? referenceId;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  NotificationCategory get category => NotificationCategory.fromType(type);

  String get timeAgo {
    final date = createdAt;
    if (date == null) return '';

    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    body,
    actionUrl,
    referenceType,
    referenceId,
    readAt,
    createdAt,
  ];
}

enum NotificationCategory {
  booking,
  consultation,
  payment,
  verification,
  system;

  static NotificationCategory fromType(String? type) {
    final value = (type ?? '').toLowerCase();

    if (value.startsWith('service_booking')) return NotificationCategory.booking;
    if (value.startsWith('consultation')) {
      return NotificationCategory.consultation;
    }
    if (value.contains('payment')) return NotificationCategory.payment;
    if (value.contains('verification')) return NotificationCategory.verification;

    return NotificationCategory.system;
  }
}
