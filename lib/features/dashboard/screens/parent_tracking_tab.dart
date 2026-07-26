import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parent_provider.dart';
import '../../tracking/screens/parent_tracking_screen.dart';
import '../../../core/constants/colors.dart';

class ParentTrackingTab extends StatelessWidget {
  const ParentTrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final parentProvider = Provider.of<ParentProvider>(context);
    final data = parentProvider.dashboardData;

    if (parentProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final driverId = data?['driverId'];

    if (driverId == null || driverId.toString().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Live Tracking'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: AppColors.outline),
              const SizedBox(height: 16),
              const Text(
                'No Driver Assigned',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please connect with a driver using their reference code.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/connectDriver');
                },
                child: const Text('Connect Driver'),
              ),
            ],
          ),
        ),
      );
    }

    // If driver is assigned, return the actual tracking screen
    return ParentTrackingScreen(driverId: driverId);
  }
}
