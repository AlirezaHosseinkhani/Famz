import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/notification/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markAllAsRead();

  Future<NotificationModel> markAsRead(int notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get(ApiConstants.notificationsEndpoint,
          expectList: true);
      // final List<dynamic> notificationsJson = response['results'] ?? response;

      return (response as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch notifications');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post(ApiConstants.markAllAsRead);
    } catch (e) {
      throw ServerException('Failed to mark all notifications as read');
    }
  }

  @override
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      final response = await apiClient.post(
        '${ApiConstants.notificationsEndpoint}$notificationId/mark_as_read/',
      );
      return NotificationModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to mark notification as read');
    }
  }
}
