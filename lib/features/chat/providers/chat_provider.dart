import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/network/api_client.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  IO.Socket? _socket;

  List<ChatConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentlyTypingUserId;

  List<ChatConversationModel> get conversations => _conversations;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentlyTypingUserId => _currentlyTypingUserId;

  // Initialize Socket Connection
  void initSocket(String currentUserId) {
    if (_socket != null && _socket!.connected) return;

    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Chat Socket Connected');
      // Tell server we are online (you can emit driverOnline or parentOnline based on role)
    });

    _socket!.on('receiveMessage', (data) {
      final message = MessageModel.fromJson(data);
      _currentMessages.insert(0, message); // Insert at beginning for reversed list
      
      // Update conversations list as well
      _updateConversationsWithNewMessage(message);
      
      notifyListeners();
    });

    _socket!.on('messageSent', (data) {
      // Message confirmed by server
      final message = MessageModel.fromJson(data);
      _currentMessages.insert(0, message);
      _updateConversationsWithNewMessage(message);
      notifyListeners();
    });

    _socket!.on('userTyping', (data) {
      _currentlyTypingUserId = data['senderId'];
      notifyListeners();
    });

    _socket!.on('userStopTyping', (data) {
      if (_currentlyTypingUserId == data['senderId']) {
        _currentlyTypingUserId = null;
        notifyListeners();
      }
    });

    _socket!.on('messageRead', (data) {
      final messageId = data['messageId'];
      _updateMessageStatus(messageId, isRead: true, seen: true);
    });

    _socket!.on('messageDeliveredConfirm', (data) {
      final messageId = data['messageId'];
      _updateMessageStatus(messageId, delivered: true);
    });

    _socket!.on('messageSeenConfirm', (data) {
      final messageId = data['messageId'];
      _updateMessageStatus(messageId, seen: true, isRead: true);
    });
  }

  void _updateMessageStatus(String messageId, {bool? isRead, bool? delivered, bool? seen}) {
    final index = _currentMessages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _currentMessages[index] = _currentMessages[index].copyWith(
        isRead: isRead,
        delivered: delivered,
        seen: seen,
      );
      notifyListeners();
    }
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }

  // Fetch Conversations
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Chat History
  Future<void> fetchChatHistory(String userId) async {
    _isLoading = true;
    _error = null;
    _currentMessages = [];
    notifyListeners();

    try {
      final fetched = await _chatService.getChatHistory(userId);
      // Force sort: newest first (index 0 is newest)
      fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _currentMessages = fetched;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send Message
  void sendMessage(String senderId, String receiverId, String text, {String? imageUrl}) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'messageType': imageUrl != null ? 'image' : 'text',
    });
  }

  // Upload Image and Send
  Future<void> sendImageMessage(String senderId, String receiverId, File imageFile, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _chatService.uploadChatImage(imageFile, token);
      if (imageUrl != null) {
        sendMessage(senderId, receiverId, '', imageUrl: imageUrl);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      _currentMessages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  // Typing Events
  void emitTyping(String senderId, String receiverId) {
    _socket?.emit('typing', {'senderId': senderId, 'receiverId': receiverId});
  }

  void emitStopTyping(String senderId, String receiverId) {
    _socket?.emit('stopTyping', {'senderId': senderId, 'receiverId': receiverId});
  }

  void emitMarkAsRead(String messageId, String senderId) {
    _socket?.emit('markAsRead', {'messageId': messageId, 'senderId': senderId});
  }

  void emitMessageDelivered(String messageId, String senderId) {
    _socket?.emit('messageDelivered', {'messageId': messageId, 'senderId': senderId});
  }

  void emitMessageSeen(String messageId, String senderId) {
    _socket?.emit('messageSeen', {'messageId': messageId, 'senderId': senderId});
  }

  void _updateConversationsWithNewMessage(MessageModel message) {
    // Basic logic to bubble up the conversation with the new message
    // Omitting full implementation for brevity, typically you'd find the convo and move it to top
  }
}
