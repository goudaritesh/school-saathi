import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../../../core/constants/colors.dart';

class DriverProfileScreen extends StatefulWidget {
  final dynamic driver;

  const DriverProfileScreen({Key? key, required this.driver}) : super(key: key);

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.driver['user'] ?? {};
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryContainer,
              child: const Icon(Icons.person, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              user['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user['phone'] ?? 'No Phone',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoRow('Vehicle', widget.driver['vehicle_no'] ?? 'N/A'),
            const Divider(),
            if (widget.driver['vehicle_model'] != null && widget.driver['vehicle_model'].isNotEmpty) ...[
              _buildInfoRow('Van Model', widget.driver['vehicle_model']),
              const Divider(),
            ],
            if (widget.driver['vehicle_color'] != null && widget.driver['vehicle_color'].isNotEmpty) ...[
              _buildInfoRow('Van Color', widget.driver['vehicle_color']),
              const Divider(),
            ],
            _buildInfoRow('Route', widget.driver['route_name'] ?? 'N/A'),
            const Divider(),
            _buildInfoRow('Experience', '${widget.driver['experience_years'] ?? 0} Years'),
            const Divider(),
            _buildInfoRow('Driver Code', widget.driver['reference_code'] ?? 'N/A'),
            const Divider(),
            _buildInfoRow('Total Seats', '${widget.driver['total_seats'] ?? 0}'),
            const Divider(),
            _buildInfoRow('Available Seats', '${widget.driver['available_seats'] ?? 0}'),
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _showConnectDialog(context, widget.driver['reference_code']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Connection Request',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showConnectDialog(BuildContext context, String? driverCode) {
    if (driverCode == null || driverCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Driver Code')),
      );
      return;
    }

    final routeAddressController = TextEditingController();
    final schoolTimingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connect to Driver'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to send a connection request to ${widget.driver['user']?['name']}?'),
              const SizedBox(height: 16),
              TextField(
                controller: routeAddressController,
                decoration: const InputDecoration(
                  labelText: 'Route Address (Home to School)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: schoolTimingController,
                decoration: const InputDecoration(
                  labelText: 'School Timing',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final route = routeAddressController.text.trim();
                final timing = schoolTimingController.text.trim();
                if (route.isEmpty || timing.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                Navigator.pop(context);
                final success = await context.read<ConnectionProvider>().sendConnectionRequest(driverCode, route, timing);
                if (success) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent successfully!')),
                    );
                    Navigator.pop(context); // Go back to list
                  }
                } else {
                  if (mounted) {
                    final errorMessage = context.read<ConnectionProvider>().errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage.isNotEmpty ? errorMessage : 'Failed to send request.')),
                    );
                  }
                }
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      }
    );
  }
}
