import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connection_provider.dart';
import '../../../core/constants/colors.dart';

class ConnectDriverScreen extends StatefulWidget {
  const ConnectDriverScreen({Key? key}) : super(key: key);

  @override
  State<ConnectDriverScreen> createState() => _ConnectDriverScreenState();
}

class _ConnectDriverScreenState extends State<ConnectDriverScreen> {
  final _codeController = TextEditingController();
  final _routeAddressController = TextEditingController();
  final _schoolTimingController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _routeAddressController.dispose();
    _schoolTimingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Driver'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Enter Driver Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in the details below to send a connection request to a driver.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Driver Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.pin),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _routeAddressController,
              decoration: InputDecoration(
                labelText: 'Route Address (Home to School)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _schoolTimingController,
              decoration: InputDecoration(
                labelText: 'School Timing',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final code = _codeController.text.trim();
                  final routeAddress = _routeAddressController.text.trim();
                  final schoolTiming = _schoolTimingController.text.trim();
                  
                  if (code.isEmpty || routeAddress.isEmpty || schoolTiming.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields.')),
                    );
                    return;
                  }

                  final success = await context.read<ConnectionProvider>().sendConnectionRequest(code, routeAddress, schoolTiming);
                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request sent successfully!')),
                      );
                      Navigator.pop(context);
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Send Request', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
