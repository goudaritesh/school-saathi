import 'package:flutter/material.dart';
import '../services/driver_service.dart';

class DriverProvider with ChangeNotifier {
  final DriverService _driverService = DriverService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _students = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get students => _students;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _dashboardData = await _driverService.getDashboardStats();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _studentFilter = 'All'; // 'All', 'Present', 'Absent'
  String get studentFilter => _studentFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<dynamic> get filteredStudents {
    List<dynamic> result = _students;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((s) {
        final name = (s['child_name'] ?? '').toString().toLowerCase();
        final parentName = (s['user']?['name'] ?? '').toString().toLowerCase();
        return name.contains(query) || parentName.contains(query);
      }).toList();
    }

    if (_studentFilter == 'Present') {
      return result.where((s) => s['today_attendance'] == 'Picked Up' || s['today_attendance'] == 'Dropped Off').toList();
    } else if (_studentFilter == 'Absent') {
      return result.where((s) => s['today_attendance'] == 'Absent').toList();
    }
    return result;
  }

  void setStudentFilter(String filter) {
    _studentFilter = filter;
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _students = await _driverService.getStudents();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAttendance(String qrCodeData, String status) async {
    try {
      await _driverService.markAttendance(qrCodeData, status);
      // Refresh students to get updated status and refresh dashboard stats
      await Future.wait([
        fetchStudents(),
        fetchDashboardStats(),
      ]);
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  Future<List<dynamic>> fetchStudentAttendanceHistory(String studentId) async {
    try {
      return await _driverService.getStudentAttendanceHistory(studentId);
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }
}
