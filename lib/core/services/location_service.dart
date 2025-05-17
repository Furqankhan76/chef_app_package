import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Check and request location permission.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    // Handle permanently denied or restricted cases if necessary
    if (status.isPermanentlyDenied) {
      // Optionally open app settings
      // openAppSettings();
      print('Location permission is permanently denied.');
      return false;
    }
    if (status.isRestricted) {
      print('Location permission is restricted.');
      return false;
    }
    return status.isGranted;
  }

  /// Get the current device location.
  /// Throws an exception if permission is denied or location service is disabled.
  Future<Position> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied.');
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      throw Exception('Location services are disabled.');
    }

    try {
      // Get current position with desired accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      // Handle specific exceptions like TimeoutException if needed
      rethrow;
    }
  }

  /// Calculate the distance between two points in meters.
  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
  }

  // Stream for location updates (useful for couriers)
  // Stream<Position> getPositionStream() {
  //   // TODO: Implement background location updates if needed for couriers
  //   // Requires careful handling of permissions (locationAlways) and battery usage
  //   return Geolocator.getPositionStream(locationSettings: const LocationSettings(
  //     accuracy: LocationAccuracy.high,
  //     distanceFilter: 10, // Update every 10 meters
  //   ));
  // }
}

// Riverpod provider for the LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

