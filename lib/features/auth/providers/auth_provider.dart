import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/firebase_messaging_service.dart';

enum UserRole { parent, driver }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.parent;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;
  String? _token;

  bool get isLoading => _isLoading;
  UserRole get selectedRole => _selectedRole;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Auto Login
  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');
    final roleString = prefs.getString('role');

    if (phone != null && password != null && roleString != null) {
      if (roleString == 'driver') {
        _selectedRole = UserRole.driver;
      } else {
        _selectedRole = UserRole.parent;
      }
      return await login(phone, password, isAutoLogin: true);
    }
    return false;
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    ApiClient().clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears stored phone and password
    notifyListeners();
  }
  
  // Send FCM Token to backend
  Future<void> sendFCMToken(String fcmToken) async {
    try {
      await ApiClient().post('/auth/fcm-token', {'fcm_token': fcmToken});
      print('FCM token sent to server');
    } catch (e) {
      print('Failed to send FCM token: $e');
    }
  }

  void setRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> login(String phone, String password, {bool isAutoLogin = false}) async {
    if (!isAutoLogin) {
      setLoading(true);
    }
    clearError();
    try {
      final response = await _authService.login(phone, password);
      
      // Check if the backend role matches the selected role
      final String backendRole = response['role']?.toString().toLowerCase() ?? '';
      final String selectedRoleStr = _selectedRole.name.toLowerCase();
      
      if (backendRole != selectedRoleStr) {
        _errorMessage = 'Account belongs to a ${_capitalize(backendRole)}. Please log in from the ${_capitalize(backendRole)} tab.';
        if (!isAutoLogin) setLoading(false);
        return false;
      }

      _currentUser = response;
      _token = response['token'];
      
      // Store credentials for auto-login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', phone);
      await prefs.setString('password', password);
      await prefs.setString('role', selectedRoleStr);
      
      // Fetch FCM Token and send to backend
      final fcmService = FirebaseMessagingService();
      final fcmToken = await fcmService.getToken();
      if (fcmToken != null) {
        await sendFCMToken(fcmToken);
      }

      if (!isAutoLogin) setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (!isAutoLogin) setLoading(false);
      return false;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<bool> registerParent(Map<String, dynamic> data) async {
    setLoading(true);
    clearError();
    try {
      await _authService.registerParent(data);
      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      setLoading(false);
      return false;
    }
  }

  Future<bool> registerDriver(Map<String, dynamic> data) async {
    setLoading(true);
    clearError();
    try {
      await _authService.registerDriver(data);
      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      setLoading(false);
      return false;
    }
  }
}
