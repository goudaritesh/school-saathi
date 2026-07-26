import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../services/payment_service.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  String? _error;
  double _totalCollected = 0;
  double _totalPending = 0;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _paymentService.getDriverEarnings();
      setState(() {
        _totalCollected = (data['totalCollected'] as num).toDouble();
        _totalPending = (data['totalPending'] as num).toDouble();
        _transactions = data['transactions'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Fees'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
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
                  'Total Collected',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_totalCollected.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Pending Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.pending_actions, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text('Pending Fees', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      Text(
                        '₹${_totalPending.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
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
                    child: Text('All Transactions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  );
                }
                
                final txn = _transactions[index - 1];
                final isPaid = txn['status'] == 'Paid';
                final childName = txn['parent_profile']?['child_name'] ?? 'Unknown Student';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green[100] : AppColors.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPaid ? Icons.arrow_downward : Icons.schedule,
                        color: isPaid ? Colors.green[800] : AppColors.error,
                      ),
                    ),
                    title: Text(childName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Van Fee - ${txn['month']}'),
                        Text(
                          isPaid ? 'Paid' : 'Pending',
                          style: TextStyle(
                            color: isPaid ? Colors.green[800] : AppColors.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        if (!isPaid)
                          TextButton(
                            onPressed: () async {
                              try {
                                await _paymentService.sendReminder(txn['_id']);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reminder sent successfully!')),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Send Reminder', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                    trailing: Text(
                      '₹${txn['amount']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
              childCount: _transactions.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}
