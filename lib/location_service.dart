import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      // 1. Check if location services enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services disabled on device.');
        return null;
      }

      // 2. Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission permanently denied.');
        return null;
      }

      debugPrint('✅ Location permission granted. Getting position...');

      // 3. Try high accuracy first with timeout
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () async {
            debugPrint('⚠️ High accuracy timeout. Trying low accuracy...');
            // Fallback to low accuracy
            return await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
            );
          },
        );

        debugPrint(
            '✅ Location obtained: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (e) {
        debugPrint('⚠️ GPS error: $e. Trying last known location...');

        // 4. Try last known position as final fallback
        Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint(
              '✅ Last known location: ${lastKnown.latitude}, ${lastKnown.longitude}');
          return lastKnown;
        }
        return null;
      }
    } catch (e) {
      debugPrint('❌ Location error: $e');
      return null;
    }
  }

  static String buildLocationLink(double lat, double lng) {
    return 'https://www.google.com/maps?q=$lat,$lng';
  }

  static String formatCoordinates(double lat, double lng) {
    return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
  }
}