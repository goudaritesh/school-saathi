import '../../../core/network/api_client.dart';

class ConnectionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getAllDrivers() async {
    final response = await _apiClient.get('/driver/all');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> sendRequest(String driverCode, String routeAddress, String schoolTiming) async {
    final response = await _apiClient.post('/connection/send-request', {
      'driverCode': driverCode,
      'routeAddress': routeAddress,
      'schoolTiming': schoolTiming,
    });
    return response;
  }

  Future<List<dynamic>> getPendingRequests() async {
    final response = await _apiClient.get('/connection/requests');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> acceptRequest(String requestId, String fees) async {
    final response = await _apiClient.put('/connection/accept/$requestId', data: {
      'fees': fees,
    });
    return response;
  }

  Future<Map<String, dynamic>> rejectRequest(String requestId, String reason) async {
    final response = await _apiClient.put('/connection/reject/$requestId', data: {
      'reason': reason,
    });
    return response;
  }

  Future<Map<String, dynamic>?> getMyRequest() async {
    try {
      final response = await _apiClient.get('/connection/my-request');
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> disconnectUser({String? targetUserId}) async {
    final response = await _apiClient.put('/connection/disconnect', data: {
      if (targetUserId != null) 'targetUserId': targetUserId,
    });
    return response;
  }
}
