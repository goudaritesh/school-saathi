import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
    } else if (_currentPage > _totalPages) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getNotifications(page: _currentPage);
      
      if (refresh) {
        _notifications = result['notifications'];
      } else {
        _notifications.addAll(result['notifications']);
      }
      
      _unreadCount = result['unreadCount'];
      _totalPages = result['totalPages'];
      _currentPage++;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final success = await _service.markAsRead(notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        // Create updated copy
        final updatedNotification = NotificationModel(
          id: _notifications[index].id,
          senderId: _notifications[index].senderId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          priority: _notifications[index].priority,
          isRead: true,
          createdAt: _notifications[index].createdAt,
          data: _notifications[index].data,
        );
        _notifications[index] = updatedNotification;
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    }
  }
}
