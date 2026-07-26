import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 10}) async {
    final response = await _apiClient.get('/notification?page=$page&limit=$limit');
    
    List<NotificationModel> notifications = [];
    if (response['notifications'] != null) {
      notifications = (response['notifications'] as List)
          .map((data) => NotificationModel.fromJson(data))
          .toList();
    }

    return {
      'notifications': notifications,
      'unreadCount': response['unreadCount'] ?? 0,
      'totalPages': response['totalPages'] ?? 1,
    };
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _apiClient.put('/notification/$notificationId/read');
      return true;
    } catch (e) {
      return false;
    }
  }
}
