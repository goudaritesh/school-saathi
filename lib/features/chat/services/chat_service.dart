import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../models/message_model.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  // Fetch chat conversations (users you have chatted with)
  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final response = await _apiClient.get('/chat/conversations');
      final List<dynamic> data = response;
      return data.map((json) => ChatConversationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching conversations: $e');
    }
  }

  // Fetch chat history with a specific user
  Future<List<MessageModel>> getChatHistory(String userId,
      {int page = 1}) async {
    try {
      final response = await _apiClient.get(
          '/chat/$userId?page=$page&limit=50');
      final List<dynamic> data = response;
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  // Upload image for chat
  Future<String?> uploadChatImage(File imageFile, String token) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiClient.baseUrl}/chat/upload-image'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['imageUrl'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading chat image: $e');
      return null;
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete('/chat/$messageId');
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }
}