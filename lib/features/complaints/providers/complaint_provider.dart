import 'dart:io';
import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();

  List<ComplaintModel> _complaints = [];
  bool _isLoading = false;
  String? _error;

  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchComplaints() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _complaints = await _complaintService.getComplaints();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitComplaint({
    required String driverId,
    required String subject,
    required String description,
    File? attachment,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newComplaint = await _complaintService.submitComplaint(
        driverId: driverId,
        subject: subject,
        description: description,
        attachment: attachment,
        token: token,
      );
      _complaints.insert(0, newComplaint);
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

  Future<bool> updateStatus(String complaintId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _complaintService.updateComplaintStatus(complaintId, status);
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = updated;
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

  Future<bool> addResponse(String complaintId, String message) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _complaintService.addResponse(complaintId, message);
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1) {
        _complaints[index] = updated;
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
