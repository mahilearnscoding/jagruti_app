import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LocationService {
  LocationService._();
  static final LocationService I = LocationService._();

  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      // Request permission
      final permission = await ph.Permission.location.request();
      if (permission != ph.PermissionStatus.granted) {
        throw Exception('Location permission denied. Please grant location permission.');
      }

      // Get current position with high accuracy for demo
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  Future<bool> hasLocationPermission() async {
    final status = await ph.Permission.location.status;
    return status == ph.PermissionStatus.granted;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await ph.Permission.location.request();
  }
}