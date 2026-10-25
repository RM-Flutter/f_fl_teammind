import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/settings/fingerprint_security_checks.model.dart';
import 'package:app_test/core/services/location_service.dart';
import 'package:app_test/core/services/time_drift_service.dart';
import 'package:app_test/core/services/vpn_detection_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class FingerprintSecurityResult {
  final bool canProceed;
  final String? mandatoryFailedKey;
  final String? mandatoryFailedMessage;
  final Map<String, dynamic> failedOptionals;
  final Map<String, dynamic>? fakeGpsCheck;
  final Map<String, dynamic>? gpsVerification;

  const FingerprintSecurityResult({
    required this.canProceed,
    this.mandatoryFailedKey,
    this.mandatoryFailedMessage,
    this.failedOptionals = const {},
    this.fakeGpsCheck,
    this.gpsVerification,
  });

  factory FingerprintSecurityResult.blocked({
    required String mandatoryFailedKey,
    required String mandatoryFailedMessage,
    Map<String, dynamic>? fakeGpsCheck,
  }) {
    return FingerprintSecurityResult(
      canProceed: false,
      mandatoryFailedKey: mandatoryFailedKey,
      mandatoryFailedMessage: mandatoryFailedMessage,
      failedOptionals: const {},
      fakeGpsCheck: fakeGpsCheck,
    );
  }

  factory FingerprintSecurityResult.allowed({
    Map<String, dynamic> failedOptionals = const {},
    Map<String, dynamic>? fakeGpsCheck,
    Map<String, dynamic>? gpsVerification,
  }) {
    return FingerprintSecurityResult(
      canProceed: true,
      failedOptionals: failedOptionals,
      fakeGpsCheck: fakeGpsCheck,
      gpsVerification: gpsVerification,
    );
  }
}

abstract class FingerprintSecurityRunner {
  static const MethodChannel _secureChannel =
      MethodChannel('com.rightminddev.rmemp/secure');

  static Future<bool> isDeveloperModeEnabled() async {
    if (kIsWeb) return false;
    try {
      final bool? value =
          await _secureChannel.invokeMethod<bool>('isDeveloperModeEnabled');
      return value ?? false;
    } catch (e) {
      debugPrint('Error checking developer mode: $e');
      return false;
    }
  }

  static Future<bool> isDeviceRootedOrJailbroken() async {
    if (kIsWeb) return false;
    try {
      final bool? value =
          await _secureChannel.invokeMethod<bool>('isDeviceRooted');
      return value ?? false;
    } catch (e) {
      debugPrint('Error checking root/jailbreak: $e');
      return false;
    }
  }

  /// التحقق من توقيت GPS في وضع الأوفلاين
  static Future<Map<String, dynamic>?> verifyGPSTimestampOffline() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location service is not enabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ Location permission denied forever');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final deviceTime = DateTime.now();
      final gpsTime = position.timestamp;

      final difference = (deviceTime.difference(gpsTime).abs().inSeconds).abs();
      final differenceInMinutes = difference / 60.0;

      final deviceTimezone = deviceTime.timeZoneOffset;
      final gpsTimezone = gpsTime.timeZoneOffset;
      final timezoneMismatch = deviceTimezone != gpsTimezone;

      if (differenceInMinutes > 2.0) {
        return {
          'gpsTimeVerificationSuspicious': true,
          'deviceTime': deviceTime.toIso8601String(),
          'gpsTime': gpsTime.toIso8601String(),
          'timeDifferenceSeconds': difference,
          'timeDifferenceMinutes': differenceInMinutes.toStringAsFixed(2),
          'deviceTimezone': deviceTimezone.toString(),
          'gpsTimezone': gpsTimezone.toString(),
          'timezoneMismatch': timezoneMismatch,
          'gpsLatitude': position.latitude,
          'gpsLongitude': position.longitude,
          'verificationMessage':
              'Time difference between device and GPS is ${differenceInMinutes.toStringAsFixed(2)} minutes (threshold: 2 minutes)',
        };
      }

      if (timezoneMismatch) {
        return {
          'gpsTimeVerificationSuspicious': true,
          'deviceTime': deviceTime.toIso8601String(),
          'gpsTime': gpsTime.toIso8601String(),
          'timeDifferenceSeconds': difference,
          'timeDifferenceMinutes': differenceInMinutes.toStringAsFixed(2),
          'deviceTimezone': deviceTimezone.toString(),
          'gpsTimezone': gpsTimezone.toString(),
          'timezoneMismatch': true,
          'gpsLatitude': position.latitude,
          'gpsLongitude': position.longitude,
          'verificationMessage':
              'Timezone mismatch detected between device and GPS',
        };
      }

      return {
        'gpsTimeVerificationSuspicious': false,
        'deviceTime': deviceTime.toIso8601String(),
        'gpsTime': gpsTime.toIso8601String(),
        'timeDifferenceSeconds': difference,
        'timeDifferenceMinutes': differenceInMinutes.toStringAsFixed(2),
        'deviceTimezone': deviceTimezone.toString(),
        'gpsTimezone': gpsTimezone.toString(),
        'timezoneMismatch': false,
        'gpsLatitude': position.latitude,
        'gpsLongitude': position.longitude,
      };
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error verifying GPS timestamp: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// تشغيل كافة فحوصات الأمان حسب مستوى كل مفتاح (mandatory / optional / disabled)
  /// - إذا فشل فحص mandatory: يتم إيقاف العملية وإرجاع canProceed = false
  /// - إذا فشل فحص optional: يتم تسجيله داخل failedOptionals والاستمرار
  static Future<FingerprintSecurityResult> runAllChecks({
    double? latitude,
    double? longitude,
    bool isOffline = false,
    Map<String, dynamic>? initialFailedOptionals,
  }) async {
    final failedOptionals = <String, dynamic>{
      if (initialFailedOptionals != null) ...initialFailedOptionals,
    };

    final nowIso = DateTime.now().toIso8601String();

    // ═════════════════════════════════════════════════════════════════════════
    // 1. block_fingerprint_on_developer_mode
    // ═════════════════════════════════════════════════════════════════════════
    final devLevel = AppConstants.blockFingerprintOnDeveloperModeLevel;
    if (devLevel != FingerprintCheckLevel.disabled) {
      final isDev = await isDeveloperModeEnabled();
      if (isDev) {
        if (devLevel == FingerprintCheckLevel.mandatory) {
          return FingerprintSecurityResult.blocked(
            mandatoryFailedKey: 'block_fingerprint_on_developer_mode',
            mandatoryFailedMessage: AppStrings.developerModeDetected.tr(),
          );
        } else {
          failedOptionals['block_fingerprint_on_developer_mode'] = {
            'status': 'failed',
            'message': 'Developer Mode is enabled on this device',
            'detected_at': nowIso,
          };
        }
      }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // 2. fingerprint_block_on_root_or_jailbreak
    // ═════════════════════════════════════════════════════════════════════════
    final rootLevel = AppConstants.fingerprintBlockOnRootOrJailbreakLevel;
    if (rootLevel != FingerprintCheckLevel.disabled) {
      final isRooted = await isDeviceRootedOrJailbroken();
      if (isRooted) {
        if (rootLevel == FingerprintCheckLevel.mandatory) {
          return FingerprintSecurityResult.blocked(
            mandatoryFailedKey: 'fingerprint_block_on_root_or_jailbreak',
            mandatoryFailedMessage: AppStrings.rootedDeviceDetected.tr(),
          );
        } else {
          failedOptionals['fingerprint_block_on_root_or_jailbreak'] = {
            'status': 'failed',
            'message': 'Device is rooted or jailbroken',
            'detected_at': nowIso,
          };
        }
      }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // 3. fingerprint_block_on_vpn
    // ═════════════════════════════════════════════════════════════════════════
    final vpnLevel = AppConstants.fingerprintBlockOnVpnLevel;
    if (vpnLevel != FingerprintCheckLevel.disabled) {
      final vpnCheck = await VpnDetectionService.checkVpn();
      if (vpnCheck['isVpnActive'] == true) {
        if (vpnLevel == FingerprintCheckLevel.mandatory) {
          return FingerprintSecurityResult.blocked(
            mandatoryFailedKey: 'fingerprint_block_on_vpn',
            mandatoryFailedMessage: AppStrings.vpnDetected.tr(),
          );
        } else {
          failedOptionals['fingerprint_block_on_vpn'] = {
            'status': 'failed',
            'message': vpnCheck['message'] ?? 'VPN connection detected',
            'interface': vpnCheck['interface'],
            'detected_at': nowIso,
          };
        }
      }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // 4. fingerprint_verify_time_drift
    // ═════════════════════════════════════════════════════════════════════════
    final timeDriftLevel = AppConstants.fingerprintVerifyTimeDriftLevel;
    if (timeDriftLevel != FingerprintCheckLevel.disabled && !isOffline) {
      final driftCheck = await TimeDriftService.checkTimeDrift();
      if (driftCheck['isDrifted'] == true) {
        if (timeDriftLevel == FingerprintCheckLevel.mandatory) {
          return FingerprintSecurityResult.blocked(
            mandatoryFailedKey: 'fingerprint_verify_time_drift',
            mandatoryFailedMessage: AppStrings.timeDriftDetected.tr(),
          );
        } else {
          failedOptionals['fingerprint_verify_time_drift'] = {
            'status': 'failed',
            'message': driftCheck['message'],
            'drift_seconds': driftCheck['drift_seconds'],
            'server_time': driftCheck['server_time'],
            'device_time': driftCheck['device_time'],
            'detected_at': nowIso,
          };
        }
      }
    }

    // ═════════════════════════════════════════════════════════════════════════
    // 5. GPS Checks (Fake GPS + Network Comparison + Offline Timestamp)
    // ═════════════════════════════════════════════════════════════════════════
    Map<String, dynamic>? fakeGPSCheck;
    final fakeGpsLevel = AppConstants.fingerprintBlockOnFakeGpsLevel;
    final networkComparisonLevel =
        AppConstants.fingerprintVerifyGpsNetworkComparisonLevel;
    final offlineTimestampLevel =
        AppConstants.fingerprintVerifyGpsTimestampOfflineLevel;

    final needsGpsCheck = fakeGpsLevel.isEnabled ||
        networkComparisonLevel.isEnabled ||
        AppConstants.fingerprintSendNoteReportToApi;

    if (needsGpsCheck) {
      try {
        final rawCheck = await LocationService.checkFakeGPS();
        if (rawCheck['isFakeGPS'] == true) {
          fakeGPSCheck = {
            'isFakeGPS': true,
            'isMockLocation': rawCheck['isMockLocation'] ?? false,
            'isLowAccuracy': rawCheck['isLowAccuracy'] ?? false,
            'isSuspiciousSpeed': rawCheck['isSuspiciousSpeed'] ?? false,
            'isSuspiciousAltitude': rawCheck['isSuspiciousAltitude'] ?? false,
            'accuracy': rawCheck['accuracy'],
            'speed': rawCheck['speed'],
            'altitude': rawCheck['altitude'],
            'latitude': rawCheck['latitude'],
            'longitude': rawCheck['longitude'],
            'message': rawCheck['message'] ?? 'Fake GPS detected',
            'blockFingerprint': true,
          };
        } else {
          final gpsLat = (latitude ?? rawCheck['latitude']) as double?;
          final gpsLon = (longitude ?? rawCheck['longitude']) as double?;

          Map<String, dynamic>? networkComparison;
          if (networkComparisonLevel.isEnabled &&
              gpsLat != null &&
              gpsLon != null) {
            networkComparison =
                await LocationService.compareGPSWithNetworkLocation(
              gpsLatitude: gpsLat,
              gpsLongitude: gpsLon,
            );
          }

          fakeGPSCheck = {
            'isFakeGPS': false,
            'isMockLocation': false,
            'latitude': gpsLat ?? rawCheck['latitude'],
            'longitude': gpsLon ?? rawCheck['longitude'],
            'accuracy': rawCheck['accuracy'],
            'message': 'GPS location is genuine',
            'blockFingerprint': false,
            'networkLocationComparison': networkComparison,
          };
        }
      } catch (e) {
        debugPrint('⚠️ Error running GPS checks: $e');
        fakeGPSCheck = {
          'isFakeGPS': false,
          'message': 'Error checking GPS: $e',
          'blockFingerprint': false,
        };
      }

      // معالجة fake GPS
      if (fakeGPSCheck?['isFakeGPS'] == true) {
        if (fakeGpsLevel == FingerprintCheckLevel.mandatory) {
          String errorMessage = fakeGPSCheck?['message'] ?? AppStrings.fakeGPSDetected.tr();
          if (fakeGPSCheck?['isMockLocation'] == true) {
            errorMessage = AppStrings.mockLocationDetected.tr();
          } else if (fakeGPSCheck?['isLowAccuracy'] == true) {
            errorMessage =
                '${AppStrings.lowGPSAccuracy.tr()}: ${fakeGPSCheck?['accuracy']?.toStringAsFixed(2) ?? 'N/A'}m';
          } else {
            errorMessage = AppStrings.suspiciousGPSData.tr();
          }
          return FingerprintSecurityResult.blocked(
            mandatoryFailedKey: 'fingerprint_block_on_fake_gps',
            mandatoryFailedMessage: errorMessage,
            fakeGpsCheck: fakeGPSCheck,
          );
        } else if (fakeGpsLevel == FingerprintCheckLevel.optional) {
          failedOptionals['fingerprint_block_on_fake_gps'] = {
            'status': 'failed',
            'message': fakeGPSCheck?['message'] ?? 'Fake GPS detected',
            'details': fakeGPSCheck,
            'detected_at': nowIso,
          };
        }
      }

      // معالجة network location comparison
      if (networkComparisonLevel.isEnabled) {
        final netComp =
            fakeGPSCheck?['networkLocationComparison'] as Map<String, dynamic>?;
        if (netComp != null && netComp['needsReview'] == true) {
          if (networkComparisonLevel == FingerprintCheckLevel.mandatory) {
            return FingerprintSecurityResult.blocked(
              mandatoryFailedKey: 'fingerprint_verify_gps_network_comparison',
              mandatoryFailedMessage:
                  netComp['message'] ?? 'GPS and Network locations mismatch',
              fakeGpsCheck: fakeGPSCheck,
            );
          } else if (networkComparisonLevel == FingerprintCheckLevel.optional) {
            failedOptionals['fingerprint_verify_gps_network_comparison'] = {
              'status': 'failed',
              'message': netComp['message'] ?? 'GPS and Network locations mismatch',
              'details': netComp,
              'detected_at': nowIso,
            };
          }
        }
      }
    }

    // معالجة GPS timestamp offline
    Map<String, dynamic>? gpsVerification;
    if (isOffline && offlineTimestampLevel.isEnabled) {
      gpsVerification = await verifyGPSTimestampOffline();
      if (gpsVerification != null &&
          gpsVerification['gpsTimeVerificationSuspicious'] == true) {
        if (offlineTimestampLevel == FingerprintCheckLevel.mandatory) {
          return FingerprintSecurityResult.blocked(
            mandatoryFailedKey: 'fingerprint_verify_gps_timestamp_offline',
            mandatoryFailedMessage:
                gpsVerification['verificationMessage'] ?? 'Offline GPS timestamp mismatch',
            fakeGpsCheck: fakeGPSCheck,
          );
        } else if (offlineTimestampLevel == FingerprintCheckLevel.optional) {
          failedOptionals['fingerprint_verify_gps_timestamp_offline'] = {
            'status': 'failed',
            'message': gpsVerification['verificationMessage'] ??
                'Offline GPS timestamp mismatch',
            'details': gpsVerification,
            'detected_at': nowIso,
          };
        }
      }
    }

    return FingerprintSecurityResult.allowed(
      failedOptionals: failedOptionals,
      fakeGpsCheck: fakeGPSCheck,
      gpsVerification: gpsVerification,
    );
  }
}
