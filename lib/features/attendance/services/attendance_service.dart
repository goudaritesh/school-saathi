import '../../../core/network/api_client.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> markAttendance(String qrCodeData, String status) async {
    return await _apiClient.post('/attendance/mark', {
      'qr_code_data': qrCodeData,
      'status': status,
    });
  }
}
