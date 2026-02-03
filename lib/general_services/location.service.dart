import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../platform/platform_is.dart';

abstract class LocationService {
  static Future<LocationData?> getLocation() async {
    if (PlatformIs.web) {
      // Web specific implementation
      return _getWebLocation();
    } else {
      return _getMobileLocation();
    }
  }

  static Future<LocationData?> _getMobileLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? locationData;

    // Check if the location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check if location permission is granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Get the location data
    locationData = await location.getLocation();
    return locationData;
  }

  static Future<LocationData?> _getWebLocation() async {
    // Web specific location logic (fallback to asking the user to enable location services)
    debugPrint('Web platform does not support location service directly.');
    return null;
  }

  /// التحقق من fake GPS و mock location
  /// Returns true if location is fake/mock, false if genuine
  static Future<Map<String, dynamic>> checkFakeGPS() async {
    try {
      if (PlatformIs.web) {
        return {
          'isFakeGPS': false,
          'isMockLocation': false,
          'message': 'Web platform does not support GPS verification',
        };
      }

      // التحقق من صلاحيات الموقع
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'isFakeGPS': true,
          'isMockLocation': false,
          'message': 'Location service is not enabled',
        };
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return {
            'isFakeGPS': true,
            'isMockLocation': false,
            'message': 'Location permission denied',
          };
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return {
          'isFakeGPS': true,
          'isMockLocation': false,
          'message': 'Location permission denied forever',
        };
      }

      // الحصول على GPS position
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // التحقق من mock location
      bool isMockLocation = position.isMocked;

      // التحقق من accuracy - إذا كانت accuracy سيئة جداً قد تكون fake
      double accuracy = position.accuracy;
      bool isLowAccuracy = accuracy > 100; // أكثر من 100 متر يعتبر دقة منخفضة

      // التحقق من speed - إذا كانت speed غير منطقية قد تكون fake
      double speed = position.speed;
      bool isSuspiciousSpeed = speed < 0;

      // التحقق من altitude - إذا كانت altitude غير منطقية قد تكون fake
      double altitude = position.altitude;
      bool isSuspiciousAltitude = altitude < -500 || altitude > 10000;

      bool isFakeGPS = isMockLocation || isLowAccuracy || isSuspiciousSpeed || isSuspiciousAltitude;

      String message = '';
      if (isMockLocation) {
        message = 'Mock location detected';
      } else if (isLowAccuracy) {
        message = 'Low GPS accuracy detected (${accuracy.toStringAsFixed(2)}m)';
      } else if (isSuspiciousSpeed) {
        message = 'Suspicious GPS speed detected';
      } else if (isSuspiciousAltitude) {
        message = 'Suspicious GPS altitude detected';
      } else {
        message = 'GPS location is genuine';
      }

      return {
        'isFakeGPS': isFakeGPS,
        'isMockLocation': isMockLocation,
        'isLowAccuracy': isLowAccuracy,
        'isSuspiciousSpeed': isSuspiciousSpeed,
        'isSuspiciousAltitude': isSuspiciousAltitude,
        'accuracy': accuracy,
        'speed': speed,
        'altitude': altitude,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'message': message,
      };
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error checking fake GPS: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'isFakeGPS': true,
        'isMockLocation': false,
        'message': 'Error checking GPS: $e',
      };
    }
  }

  /// الحصول على Network Location (موقع الشبكة)
  /// يستخدم دقة منخفضة للحصول على موقع من الشبكة بدلاً من GPS
  static Future<Map<String, dynamic>?> getNetworkLocation() async {
    try {
      if (PlatformIs.web) {
        return null;
      }

      // التحقق من صلاحيات الموقع
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return null;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return null;
      }

      // الحصول على Network Location باستخدام دقة منخفضة
      geo.Position networkPosition = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'latitude': networkPosition.latitude,
        'longitude': networkPosition.longitude,
        'accuracy': networkPosition.accuracy,
      };
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error getting Network Location: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// مقارنة GPS Location مع Network Location
  /// يقبل الفارق حتى 300 متر، وإلا يسجل أن البصمة قد تحتاج مراجعة
  static Future<Map<String, dynamic>?> compareGPSWithNetworkLocation({
    required double gpsLatitude,
    required double gpsLongitude,
  }) async {
    try {
      // الحصول على Network Location
      final networkLocation = await getNetworkLocation();
      
      if (networkLocation == null) {
        debugPrint('⚠️ Could not get Network Location for comparison');
        return {
          'comparisonAvailable': false,
          'message': 'Network Location غير متاح للمقارنة',
        };
      }

      final networkLat = networkLocation['latitude'] as double;
      final networkLon = networkLocation['longitude'] as double;

      // حساب المسافة بين GPS و Network Location بالمتر
      final distanceInMeters = geo.Geolocator.distanceBetween(
        gpsLatitude,
        gpsLongitude,
        networkLat,
        networkLon,
      );

      // الحد الأقصى للفارق المقبول: 300 متر
      const double maxAcceptedDistance = 300.0;
      final bool isWithinAcceptedRange = distanceInMeters <= maxAcceptedDistance;

      if (isWithinAcceptedRange) {
        debugPrint('✅ GPS and Network Location are within acceptable range: ${distanceInMeters.toStringAsFixed(2)}m');
        return {
          'comparisonAvailable': true,
          'isWithinAcceptedRange': true,
          'distanceInMeters': distanceInMeters,
          'gpsLatitude': gpsLatitude,
          'gpsLongitude': gpsLongitude,
          'networkLatitude': networkLat,
          'networkLongitude': networkLon,
          'maxAcceptedDistance': maxAcceptedDistance,
          'message': 'GPS و Network Location متقاربان (${distanceInMeters.toStringAsFixed(2)}m)',
        };
      } else {
        debugPrint('⚠️ GPS and Network Location differ significantly: ${distanceInMeters.toStringAsFixed(2)}m (threshold: ${maxAcceptedDistance}m)');
        return {
          'comparisonAvailable': true,
          'isWithinAcceptedRange': false,
          'distanceInMeters': distanceInMeters,
          'gpsLatitude': gpsLatitude,
          'gpsLongitude': gpsLongitude,
          'networkLatitude': networkLat,
          'networkLongitude': networkLon,
          'maxAcceptedDistance': maxAcceptedDistance,
          'needsReview': true,
          'message': 'البصمة قد تحتاج مراجعة: Network Location مختلف عن GPS (${distanceInMeters.toStringAsFixed(2)}m)',
        };
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error comparing GPS with Network Location: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'comparisonAvailable': false,
        'message': 'خطأ في مقارنة GPS مع Network Location: $e',
      };
    }
  }
}
