import '../../../core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await _apiClient.post('/auth/login', {
      'phone': phone,
      'password': password,
    });
    
    if (response['token'] != null) {
      await _storage.write(key: 'jwt_token', value: response['token']);
    }
    if (response['refreshToken'] != null) {
      await _storage.write(key: 'refresh_token', value: response['refreshToken']);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> registerParent(Map<String, dynamic> data) async {
    data['role'] = 'Parent';
    final response = await _apiClient.post('/auth/register', data);
    
    if (response['token'] != null) {
      await _storage.write(key: 'jwt_token', value: response['token']);
    }
    if (response['refreshToken'] != null) {
      await _storage.write(key: 'refresh_token', value: response['refreshToken']);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> data) async {
    data['role'] = 'Driver';
    final response = await _apiClient.post('/auth/register', data);
    
    if (response['token'] != null) {
      await _storage.write(key: 'jwt_token', value: response['token']);
    }
    if (response['refreshToken'] != null) {
      await _storage.write(key: 'refresh_token', value: response['refreshToken']);
    }
    
    return response;
  }
}
