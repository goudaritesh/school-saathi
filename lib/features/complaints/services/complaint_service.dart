import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ComplaintModel>> getComplaints() async {
    final response = await _apiClient.get('/complaints');
    final List data = response;
    return data.map((e) => ComplaintModel.fromJson(e)).toList();
  }

  Future<ComplaintModel> submitComplaint({
    required String driverId,
    required String subject,
    required String description,
    File? attachment,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiClient.baseUrl}/complaints'),
      );
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      request.fields['driverId'] = driverId;
      request.fields['subject'] = subject;
      request.fields['description'] = description;
      
      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return ComplaintModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to submit complaint');
      }
    } catch (e) {
      throw Exception('Error submitting complaint: $e');
    }
  }

  Future<ComplaintModel> updateComplaintStatus(String complaintId, String status) async {
    final response = await _apiClient.put('/complaints/$complaintId/status', data: {'status': status});
    return ComplaintModel.fromJson(response);
  }

  Future<ComplaintModel> addResponse(String complaintId, String message) async {
    final response = await _apiClient.post('/complaints/$complaintId/respond', {'message': message});
    return ComplaintModel.fromJson(response);
  }
}
