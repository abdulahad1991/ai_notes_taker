import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  String? _userRegion;
  String? _userCountry;
  String? _userCity;
  double? _latitude;
  double? _longitude;

  String? get userRegion => _userRegion;
  String? get userCountry => _userCountry;
  String? get userCity => _userCity;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  /// Check if location permission is granted
  Future<bool> _checkLocationPermission() async {
    final permission = await Permission.location.status;
    if (permission.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }
    return permission.isGranted;
  }

  /// Check if location services are enabled
  Future<bool> _checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current position with timeout and accuracy settings
  Future<Position?> _getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      // Try to get last known position as fallback
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (e) {
        print('Error getting last known position: $e');
        return null;
      }
    }
  }

  /// Convert coordinates to address information
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _userRegion = placemark.administrativeArea; // State/Region
        _userCountry = placemark.country;
        _userCity = placemark.locality;
        _latitude = latitude;
        _longitude = longitude;
        
        print('Location details:');
        print('Country: $_userCountry');
        print('Region/State: $_userRegion');
        print('City: $_userCity');
        print('Coordinates: $latitude, $longitude');
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
    }
  }

  /// Main method to get user's region
  Future<Map<String, dynamic>?> getUserRegion() async {
    try {
      // Check location permission
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      // Check if location services are enabled
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Get current position
      final position = await _getCurrentPosition();
      if (position == null) {
        print('Could not get current position');
        return null;
      }

      // Convert coordinates to address
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Return region information
      return {
        'region': _userRegion,
        'country': _userCountry,
        'city': _userCity,
        'latitude': _latitude,
        'longitude': _longitude,
        'timezone': DateTime.now().timeZoneName,
      };
    } catch (e) {
      print('Error getting user region: $e');
      return null;
    }
  }

  /// Get a simplified region string for API calls
  String getRegionString() {
    if (_userRegion != null && _userCountry != null) {
      return '$_userRegion, $_userCountry';
    } else if (_userCountry != null) {
      return _userCountry!;
    }
    return 'Unknown';
  }

  /// Reset stored location data
  void clearLocationData() {
    _userRegion = null;
    _userCountry = null;
    _userCity = null;
    _latitude = null;
    _longitude = null;
  }
}