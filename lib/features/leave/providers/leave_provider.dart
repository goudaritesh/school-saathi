import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';

class LeaveProvider with ChangeNotifier {
  final LeaveService _leaveService = LeaveService();

  List<LeaveModel> _leaves = [];
  bool _isLoading = false;
  String? _error;

  List<LeaveModel> get leaves => _leaves;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchParentLeaves() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaves = await _leaveService.getParentLeaves();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDriverLeaves() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaves = await _leaveService.getDriverLeaves();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyLeave(Map<String, dynamic> leaveData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newLeave = await _leaveService.applyLeave(leaveData);
      _leaves.insert(0, newLeave);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLeaveStatus(String leaveId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedLeave = await _leaveService.updateLeaveStatus(leaveId, status);
      final index = _leaves.indexWhere((l) => l.id == leaveId);
      if (index != -1) {
        _leaves[index] = updatedLeave;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
