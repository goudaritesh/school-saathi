import '../../../core/network/api_client.dart';

class ParentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _apiClient.get('/parent/dashboard');
  }

  Future<Map<String, dynamic>> updateChildDetails(Map<String, dynamic> data) async {
    return await _apiClient.put('/parent/child', data: data);
  }
}
