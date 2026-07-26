import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/colors.dart';
import '../services/payment_service.dart';

class ParentPaymentScreen extends StatefulWidget {
  const ParentPaymentScreen({super.key});

  @override
  State<ParentPaymentScreen> createState() => _ParentPaymentScreenState();
}

class _ParentPaymentScreenState extends State<ParentPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  late Razorpay _razorpay;
  List<dynamic> _invoices = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;
  
  // Track which invoice is currently being paid
  String? _currentPaymentId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchInvoices();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final invoices = await _paymentService.getInvoices();
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startPayment(Map<String, dynamic> invoice) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      _currentPaymentId = invoice['_id'];
      
      // 1. Create order on the backend
      final orderData = await _paymentService.createOrder(_currentPaymentId!);
      
      // 2. Configure Razorpay options
      var options = {
        'key': dotenv.env['RAZORPAY_KEY_ID'] ?? '', // Loaded from .env
        'amount': orderData['amount'], 
        'name': 'School Van Connect',
        'order_id': orderData['orderId'], 
        'description': 'Fee for ${invoice['month']}',
        'prefill': {
          'contact': '9876543210',
          'email': 'parent@example.com'
        }
      };

      // 3. Open Razorpay Checkout
      _razorpay.open(options);
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate payment: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // 4. Verify payment on the backend
      await _paymentService.verifyPayment({
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
        'payment_id': _currentPaymentId,
      });

      setState(() {
        _isProcessing = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful! Receipt generated.'), backgroundColor: Colors.green),
      );

      _fetchInvoices(); // Refresh the list
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verification failed: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: AppColors.error),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet selected: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Payments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Stack(
                  children: [
                    _buildBody(),
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildBody() {
    final pendingInvoices = _invoices.where((i) => i['status'] == 'Pending').toList();
    final totalDue = pendingInvoices.fold<double>(
        0, (sum, item) => sum + (item['amount'] as num).toDouble());

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Due Amount',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${totalDue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (pendingInvoices.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startPayment(pendingInvoices.first),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('PAY NOW VIA RAZORPAY', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('All fees are paid up to date!', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16, top: 8),
                    child: Text('Billing History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                }
                final invoice = _invoices[index - 1];
                final isPending = invoice['status'] == 'Pending';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPending ? AppColors.errorContainer : Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPending ? Icons.receipt_long : Icons.check,
                        color: isPending ? AppColors.error : Colors.green[800],
                      ),
                    ),
                    title: Text('Van Fee - ${invoice['month']}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      isPending ? 'Payment Required' : 'Txn: ${invoice['transaction_id']}',
                      style: TextStyle(color: isPending ? AppColors.error : Colors.grey),
                    ),
                    trailing: Text(
                      '₹${invoice['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: isPending ? () => _startPayment(invoice) : null,
                  ),
                );
              },
              childCount: _invoices.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}
