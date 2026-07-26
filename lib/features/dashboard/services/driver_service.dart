import '../../../core/network/api_client.dart';

class DriverService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _apiClient.get('/driver/dashboard');
  }

  Future<List<dynamic>> getStudents() async {
    return await _apiClient.get('/driver/students');
  }

  Future<void> markAttendance(String qrCodeData, String status) async {
    await _apiClient.post('/attendance/mark', {
      'qr_code_data': qrCodeData,
      'status': status,
    });
  }

  Future<List<dynamic>> getStudentAttendanceHistory(String studentId) async {
    return await _apiClient.get('/driver/student/$studentId/attendance');
  }
}
