import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/leave_provider.dart';
import '../../dashboard/providers/parent_provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({Key? key}) : super(key: key);

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _studentNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaveProvider>(context, listen: false).fetchParentLeaves();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitLeave() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      final parentProvider = Provider.of<ParentProvider>(context, listen: false);
      final driverId = parentProvider.dashboardData?['driverId']; // Assumes connected driver info is here
      
      if (driverId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No connected driver found.')));
        return;
      }

      final leaveData = {
        'driverId': driverId,
        'studentName': _studentNameController.text.trim(),
        'startDate': _startDate!.toIso8601String(),
        'endDate': _endDate!.toIso8601String(),
        'reason': _reasonController.text.trim(),
      };

      final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
      final success = await leaveProvider.applyLeave(leaveData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave applied successfully!')));
        _reasonController.clear();
        _studentNameController.clear();
        setState(() {
          _startDate = null;
          _endDate = null;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${leaveProvider.error}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select dates.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _studentNameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_startDate == null 
                                ? 'Start Date' 
                                : DateFormat('MMM d, yyyy').format(_startDate!)),
                              onPressed: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_endDate == null 
                                ? 'End Date' 
                                : DateFormat('MMM d, yyyy').format(_endDate!)),
                              onPressed: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Leave',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Consumer<LeaveProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            onPressed: provider.isLoading ? null : _submitLeave,
                            child: provider.isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit Leave Request'),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Leave History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer<LeaveProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.leaves.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.leaves.isEmpty) {
                  return const Center(child: Text('No leave history.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.leaves.length,
                  itemBuilder: (context, index) {
                    final leave = provider.leaves[index];
                    return Card(
                      child: ListTile(
                        title: Text('${leave.studentName} - ${leave.reason}'),
                        subtitle: Text('${DateFormat('MMM d').format(leave.startDate)} to ${DateFormat('MMM d').format(leave.endDate)}'),
                        trailing: Chip(
                          label: Text(leave.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                          backgroundColor: leave.status == 'approved' ? Colors.green[100] 
                                         : leave.status == 'rejected' ? Colors.red[100] : Colors.orange[100],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
