import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';

class ParentTrackingScreen extends StatefulWidget {
  final String driverId;

  const ParentTrackingScreen({super.key, required this.driverId});

  @override
  State<ParentTrackingScreen> createState() => _ParentTrackingScreenState();
}

class _ParentTrackingScreenState extends State<ParentTrackingScreen> {
  IO.Socket? _socket;
  final MapController _mapController = MapController();
  
  // Default center (e.g. city center)
  LatLng _vanPosition = const LatLng(0, 0); 
  bool _hasLocation = false;
  bool _isDriverOnline = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    _socket?.onConnect((_) {
      print('Parent Tracking Socket connected');
      // If we need to notify server
      _socket?.emit('parentOnline', widget.driverId);
    });

    _socket?.onConnectError((err) => print('Socket Connect Error: $err'));
    _socket?.onError((err) => print('Socket Error: $err'));

    _socket?.on('driverStatus', (data) {
      if (data != null && data['driverId'] == widget.driverId) {
        setState(() {
          _isDriverOnline = data['status'] == 'online';
        });
      }
    });

    // Listen for updates specific to this parent's driver
    _socket?.on('driverLocationUpdate_${widget.driverId}', (data) {
      if (data != null && data['lat'] != null && data['lng'] != null) {
        final newPosition = LatLng(data['lat'].toDouble(), data['lng'].toDouble());
        
        setState(() {
          _vanPosition = newPosition;
          _hasLocation = true;
        });

        // Smoothly animate camera to new position
        _mapController.move(newPosition, 16.0);
      }
    });

    _socket?.connect();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _hasLocation
              ? FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _vanPosition,
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.school_sathi',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _vanPosition,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.directions_bus,
                            color: Colors.orange,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Waiting for van location...'),
                    ],
                  ),
                ),
          
          // Bottom Status Card
          if (_hasLocation)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_bus, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Van Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Live location active', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _isDriverOnline ? Colors.green : Colors.grey,
                          size: 12,
                        ),
                        Text(
                          _isDriverOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isDriverOnline ? Colors.green : Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
