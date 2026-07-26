import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/leave_provider.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({Key? key}) : super(key: key);

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaveProvider>(context, listen: false).fetchDriverLeaves();
    });
  }

  void _updateStatus(String leaveId, String status) async {
    final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
    final success = await leaveProvider.updateLeaveStatus(leaveId, status);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave marked as $status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.leaves.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.leaves.isEmpty) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          if (provider.leaves.isEmpty) {
            return const Center(child: Text('No leave requests.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchDriverLeaves(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.leaves.length,
              itemBuilder: (context, index) {
                final leave = provider.leaves[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              leave.studentName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Chip(
                              label: Text(leave.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                              backgroundColor: leave.status == 'approved' ? Colors.green[100] 
                                             : leave.status == 'rejected' ? Colors.red[100] : Colors.orange[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Parent: ${leave.parentName ?? 'Unknown'} (${leave.parentPhone ?? ''})'),
                        Text('Dates: ${DateFormat('MMM d, yyyy').format(leave.startDate)} - ${DateFormat('MMM d, yyyy').format(leave.endDate)}'),
                        const SizedBox(height: 8),
                        Text('Reason: ${leave.reason}', style: const TextStyle(fontStyle: FontStyle.italic)),
                        
                        if (leave.status == 'pending') ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _updateStatus(leave.id, 'rejected'),
                                child: const Text('Reject', style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _updateStatus(leave.id, 'approved'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Approve', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
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
