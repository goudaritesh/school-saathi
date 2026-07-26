import 'package:flutter/material.dart';
import '../services/connection_service.dart';

class ConnectionProvider with ChangeNotifier {
  final ConnectionService _service = ConnectionService();

  List<dynamic> _drivers = [];
  List<dynamic> _pendingRequests = [];
  Map<String, dynamic>? _myRequest;
  
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get drivers => _drivers;
  List<dynamic> get pendingRequests => _pendingRequests;
  Map<String, dynamic>? get myRequest => _myRequest;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> fetchAllDrivers() async {
    _setLoading(true);
    clearError();
    try {
      _drivers = await _service.getAllDrivers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendConnectionRequest(String driverCode, String routeAddress, String schoolTiming) async {
    _setLoading(true);
    clearError();
    try {
      await _service.sendRequest(driverCode, routeAddress, schoolTiming);
      await fetchMyRequest(); // Refresh status
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPendingRequests() async {
    _setLoading(true);
    clearError();
    try {
      _pendingRequests = await _service.getPendingRequests();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptRequest(String requestId, String fees) async {
    _setLoading(true);
    clearError();
    try {
      await _service.acceptRequest(requestId, fees);
      _pendingRequests.removeWhere((req) => req['_id'] == requestId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectRequest(String requestId, String reason) async {
    _setLoading(true);
    clearError();
    try {
      await _service.rejectRequest(requestId, reason);
      _pendingRequests.removeWhere((req) => req['_id'] == requestId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyRequest() async {
    _setLoading(true);
    clearError();
    try {
      _myRequest = await _service.getMyRequest();
    } catch (e) {
      // It might be 404 meaning no request
      _myRequest = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> disconnectUser({String? targetUserId}) async {
    _setLoading(true);
    clearError();
    try {
      await _service.disconnectUser(targetUserId: targetUserId);
      await fetchMyRequest(); // Refresh status to disconnected
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
