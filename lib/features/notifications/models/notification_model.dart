class NotificationModel {
  final String id;
  final String senderId;
  final String type;
  final String title;
  final String message;
  final String priority;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      senderId: json['senderId']?['_id'] ?? json['senderId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'Medium',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      data: json['data'] ?? {},
    );
  }
}
