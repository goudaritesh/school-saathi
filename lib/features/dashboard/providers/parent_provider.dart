import 'package:flutter/material.dart';
import '../services/parent_service.dart';

class ParentProvider with ChangeNotifier {
  final ParentService _parentService = ParentService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  Map<String, dynamic>? _dashboardData;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _dashboardData = await _parentService.getDashboardStats();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateChildDetails(Map<String, dynamic> data) async {
    _errorMessage = '';
    notifyListeners();

    try {
      await _parentService.updateChildDetails(data);
      // Re-fetch dashboard stats after successful update
      await fetchDashboardStats();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
