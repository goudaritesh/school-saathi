import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // --- ENVIRONMENT URLS ---
  
  // 1. For Local Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // 2. For Local Physical Device Testing (Your PC's IP):
  // static const String baseUrl = 'http://192.168.1.22:5000/api'; 
  
  // 3. For PRODUCTION (Render.com):
  static const String baseUrl = 'https://school-saathi-api.onrender.com/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<dynamic> _executeWithRetry(Future<http.Response> Function() requestFunc) async {
    try {
      var response = await requestFunc();
      
      if (response.statusCode == 401) {
        // Attempt to refresh the token
        final refreshSuccess = await _refreshToken();
        if (refreshSuccess) {
          // Retry the request with the new token
          response = await requestFunc();
        } else {
          // Refresh failed, clear tokens and throw error
          await clearToken();
          throw Exception('Session expired. Please log in again.');
        }
      }
      
      return _parseResponse(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  dynamic _parseResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'An error occurred');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      return await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 120));
    });
  }

  Future<dynamic> get(String endpoint) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      return await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 120));
    });
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      return await http.put(
        url,
        headers: headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(const Duration(seconds: 120));
    });
  }

  Future<dynamic> delete(String endpoint) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      return await http.delete(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 120));
    });
  }

  Future<dynamic> uploadFile(String endpoint, String filePath) async {
    return _executeWithRetry(() async {
      final url = Uri.parse('$baseUrl$endpoint');
      final token = await _storage.read(key: 'jwt_token');
      
      var request = http.MultipartRequest('POST', url);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      var streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    });
  }
}
