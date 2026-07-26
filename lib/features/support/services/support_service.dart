import 'package:school_sathi/core/network/api_client.dart';

class SupportService {
  final ApiClient _apiClient = ApiClient();

  Future<String?> createTicket(String subject, String message) async {
    try {
      await _apiClient.post(
        '/support',
        {
          'subject': subject,
          'message': message,
        },
      );
      return null;
    } catch (e) {
      print('Error creating support ticket: $e');
      return e.toString();
    }
  }
}
