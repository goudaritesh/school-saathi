import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();

  AttendanceReport? _attendanceReport;
  FinancialReport? _financialReport;
  PerformanceReport? _performanceReport;
  
  bool _isLoading = false;
  String? _error;

  AttendanceReport? get attendanceReport => _attendanceReport;
  FinancialReport? get financialReport => _financialReport;
  PerformanceReport? get performanceReport => _performanceReport;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getAttendanceReport(),
        _service.getFinancialReport(),
        _service.getPerformanceReport(),
      ]);

      _attendanceReport = results[0] as AttendanceReport;
      _financialReport = results[1] as FinancialReport;
      _performanceReport = results[2] as PerformanceReport;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
