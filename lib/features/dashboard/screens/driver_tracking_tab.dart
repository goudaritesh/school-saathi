import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/colors.dart';
import '../../tracking/services/driver_tracking_service.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class DriverTrackingTab extends StatefulWidget {
  const DriverTrackingTab({super.key});

  @override
  State<DriverTrackingTab> createState() => _DriverTrackingTabState();
}

class _DriverTrackingTabState extends State<DriverTrackingTab> {
  final DriverTrackingService _trackingService = DriverTrackingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Switch(
            value: _trackingService.isTracking,
            onChanged: (val) {
              setState(() {
                if (val) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final driverId = authProvider.currentUser?['_id'] ?? authProvider.currentUser?['id'] ?? 'unknown_driver';
                  _trackingService.startTracking(driverId);
                } else {
                  _trackingService.stopTracking();
                }
              });
            },
            activeColor: Colors.white,
          )
        ],
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map Placeholder
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(20.5937, 78.9629), // Default center (India)
                initialZoom: 5.0,
                interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.school_sathi',
                ),
              ],
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
              ),
            ),
          ),
          
          // Info Panel
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        _trackingService.isTracking ? Icons.sensors : Icons.sensors_off,
                        color: _trackingService.isTracking ? AppColors.secondary : AppColors.outline,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _trackingService.isTracking ? 'Broadcasting Live Location' : 'Location Broadcast Offline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _trackingService.isTracking ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Keep this switch enabled during your trip so parents can see your live location on their map.',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
