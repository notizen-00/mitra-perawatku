import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_helpers.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'per_page': 50},
      );

      return jsonList(response).map(_notification).toList();
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      await _apiClient.patch('${ApiEndpoints.notifications}/$id/read');
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('${ApiEndpoints.notifications}/read-all');
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  @override
  Future<void> deleteNotification(int id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.notifications}/$id');
    } on ApiException catch (error) {
      throw ServerFailure(error.message);
    }
  }

  AppNotification _notification(Map<String, dynamic> json) {
    final data = json['data'];
    final Map<String, dynamic> dataMap = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{};

    return AppNotification(
      id: asInt(json['id']),
      userId: asInt(json['user_id']),
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? 'Notifikasi',
      body: json['body']?.toString() ?? '',
      actionUrl: json['action_url']?.toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: asInt(json['reference_id']),
      data: dataMap,
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
