
import '../../../core/network/api_client.dart';
import '../models/leave_model.dart';

class LeaveService {
  final ApiClient _apiClient = ApiClient();

  Future<LeaveModel> applyLeave(Map<String, dynamic> leaveData) async {
    final response = await _apiClient.post('/leave/apply', leaveData);
    return LeaveModel.fromJson(response);
  }

  Future<LeaveModel> updateLeaveStatus(String leaveId, String status) async {
    final response = await _apiClient.put('/leave/$leaveId/status', data: {'status': status});
    return LeaveModel.fromJson(response);
  }

  Future<List<LeaveModel>> getParentLeaves() async {
    final response = await _apiClient.get('/leave/parent');
    final List data = response;
    return data.map((e) => LeaveModel.fromJson(e)).toList();
  }

  Future<List<LeaveModel>> getDriverLeaves() async {
    final response = await _apiClient.get('/leave/driver');
    final List data = response;
    return data.map((e) => LeaveModel.fromJson(e)).toList();
  }
}
