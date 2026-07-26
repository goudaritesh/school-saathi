import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../../../core/constants/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Attendance':
        return Icons.how_to_reg;
      case 'Pickup':
        return Icons.directions_bus;
      case 'Drop':
        return Icons.home;
      case 'Fee Reminder':
      case 'Payment':
        return Icons.payment;
      case 'Emergency':
        return Icons.warning;
      case 'Delay':
        return Icons.access_time;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForPriority(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.error;
      case 'Low':
        return Colors.green;
      case 'Medium':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty && provider.isLoading) {
            return const ShimmerList();
          }

          if (provider.notifications.isEmpty) {
            return EmptyStateWidget(
              message: 'No notifications yet.',
              icon: Icons.notifications_off,
              retryLabel: 'Refresh',
              onRetry: () => provider.fetchNotifications(refresh: true),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final notification = provider.notifications[index];
                final isUnread = !notification.isRead;

                return Card(
                  elevation: 0,
                  color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isUnread ? AppColors.primary.withOpacity(0.3) : Colors.grey.shade200,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: _getColorForPriority(notification.priority).withOpacity(0.1),
                      child: Icon(
                        _getIconForType(notification.type),
                        color: _getColorForPriority(notification.priority),
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message),
                        const SizedBox(height: 8),
                        Text(
                          timeago.format(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (isUnread) {
                        provider.markAsRead(notification.id);
                      }
                      // Handle deep linking based on type here if needed
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
