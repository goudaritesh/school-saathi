class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final String messageType;
  final bool isRead;
  final bool delivered;
  final bool seen;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    this.messageType = 'text',
    required this.isRead,
    this.delivered = false,
    this.seen = false,
    required this.createdAt,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    String? imageUrl,
    String? messageType,
    bool? isRead,
    bool? delivered,
    bool? seen,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      delivered: delivered ?? this.delivered,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      senderId: json['sender'] ?? '',
      receiverId: json['receiver'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      messageType: json['messageType'] ?? 'text',
      isRead: json['isRead'] ?? false,
      delivered: json['delivered'] ?? false,
      seen: json['seen'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
    };
  }
}

class ChatConversationModel {
  final Map<String, dynamic> user;
  final MessageModel lastMessage;

  ChatConversationModel({
    required this.user,
    required this.lastMessage,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      user: json['user'] ?? {},
      lastMessage: MessageModel.fromJson(json['lastMessage'] ?? {}),
    );
  }
}
