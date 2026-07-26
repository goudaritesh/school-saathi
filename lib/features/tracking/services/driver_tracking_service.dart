import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/network/api_client.dart';

class DriverTrackingService {
  IO.Socket? _socket;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  void initSocket(String driverId) {
    // Note: We use the base URL from ApiClient to match the backend
    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');
    
    _socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket?.onConnect((_) {
      print('Socket connected for tracking');
      _socket?.emit('driverOnline', driverId);
    });

    _socket?.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket?.connect();
  }

  Future<void> startTracking(String driverId) async {
    if (_socket == null) initSocket(driverId);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    _isTracking = true;

    // Set settings for stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null && _socket != null && _socket!.connected) {
          _socket!.emit('updateLocation', {
            'driverId': driverId,
            'lat': position.latitude,
            'lng': position.longitude,
          });
        }
      },
    );
  }

  void stopTracking() {
    _positionStream?.cancel();
    _isTracking = false;
  }

  void dispose() {
    stopTracking();
    _socket?.disconnect();
    _socket?.dispose();
  }
}
