import '../../../core/network/api_client.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> getInvoices() async {
    return await _apiClient.get('/payment/invoices');
  }

  Future<Map<String, dynamic>> createOrder(String paymentId) async {
    return await _apiClient.post('/payment/create-order', {
      'payment_id': paymentId,
    });
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> data) async {
    return await _apiClient.post('/payment/verify', data);
  }

  Future<Map<String, dynamic>> getDriverEarnings() async {
    return await _apiClient.get('/payment/earnings');
  }

  Future<Map<String, dynamic>> sendReminder(String paymentId) async {
    return await _apiClient.post('/payment/remind/$paymentId', {});
  }
}
