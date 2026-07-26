import '../../../core/network/api_client.dart';
import '../models/report_model.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  Future<AttendanceReport> getAttendanceReport() async {
    final response = await _apiClient.get('/reports/attendance');
    return AttendanceReport.fromJson(response);
  }

  Future<FinancialReport> getFinancialReport() async {
    final response = await _apiClient.get('/reports/financials');
    return FinancialReport.fromJson(response);
  }

  Future<PerformanceReport> getPerformanceReport() async {
    final response = await _apiClient.get('/reports/performance');
    return PerformanceReport.fromJson(response);
  }
}
