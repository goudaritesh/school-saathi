import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/complaint_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'submit_complaint_screen.dart';
import 'complaint_details_screen.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_widget.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context, listen: false).currentUser?['role'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints & Issues'),
      ),
      floatingActionButton: role == 'Parent'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.complaints.isEmpty) {
            return const ShimmerList();
          }
          if (provider.error != null && provider.complaints.isEmpty) {
            return EmptyStateWidget(
              message: 'Error: ${provider.error}',
              icon: Icons.error_outline,
              retryLabel: 'Retry',
              onRetry: () => provider.fetchComplaints(),
            );
          }
          if (provider.complaints.isEmpty) {
            return EmptyStateWidget(
              message: 'No complaints found.',
              icon: Icons.inbox,
              retryLabel: 'Refresh',
              onRetry: () => provider.fetchComplaints(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchComplaints(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.complaints.length,
              itemBuilder: (context, index) {
                final complaint = provider.complaints[index];
                
                Color statusColor;
                switch (complaint.status) {
                  case 'resolved': statusColor = Colors.green; break;
                  case 'in-progress': statusColor = Colors.orange; break;
                  default: statusColor = Colors.red;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            complaint.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            complaint.status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          role == 'Parent' 
                              ? 'Against: ${complaint.driverName}'
                              : 'From: ${complaint.parentName}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy - h:mm a').format(complaint.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetailsScreen(complaint: complaint),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
