import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/device_information.model.dart';
import '../platform/platform_is.dart';
import 'app_config_service.dart';
import 'dart:html' if (dart.library.io) 'dart_html_stub.dart' as html;

import 'backend_services/api_service/dio_api_service/shared.dart';

abstract class DeviceInformationService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const Uuid _uuid = Uuid();

  /// Default maximum length for a sanitized device unique ID.
  /// 64 characters is optimal for HTTP headers, URLs, and database column constraints.
  static const int maxDeviceIdLength = 64;

  /// Sanitizes any raw device ID into a safe, standard slug:
  /// - Converts spaces, slashes (`/`, `\`), colons, and special characters to dashes (`-`).
  /// - Strips invalid characters (keeping only a-z, 0-9, and `-`).
  /// - Collapses multiple consecutive dashes into a single dash.
  /// - Trims leading and trailing dashes.
  /// - Enforces lowercase format.
  /// - Enforces [maxLength] (defaults to 64). If truncated, preserves uniqueness via a hash suffix.
  static String sanitizeDeviceId(String? rawId, {int maxLength = maxDeviceIdLength}) {
    if (rawId == null || rawId.trim().isEmpty || rawId.trim() == "null") {
      return "device-${DateTime.now().millisecondsSinceEpoch}";
    }

    String sanitized = rawId.trim();

    // 1. Replace slashes, backslashes, spaces, colons, semicolons, brackets, etc. with dash
    sanitized = sanitized.replaceAll(RegExp(r'[\s/\\+:;|=,()\[\]{}<>?"`~*!@#$%^&]+'), '-');

    // 2. Replace any remaining non-alphanumeric characters (except dash and underscore) with dash
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');

    // 3. Convert underscores to dashes for consistency and collapse consecutive dashes
    sanitized = sanitized.replaceAll(RegExp(r'[-_]+'), '-');

    // 4. Remove leading and trailing dashes
    sanitized = sanitized.replaceAll(RegExp(r'^-+|-+$'), '');

    // 5. Convert to lowercase for clean uniformity
    sanitized = sanitized.toLowerCase();

    // Fallback if string became empty after stripping
    if (sanitized.isEmpty) {
      sanitized = "device-${DateTime.now().millisecondsSinceEpoch}";
    }

    // 6. Enforce maximum length limit
    if (sanitized.length > maxLength) {
      // Append a short hash of the raw string to guarantee uniqueness when truncated
      final hash = rawId.hashCode.abs().toRadixString(16);
      final keepLength = maxLength - hash.length - 1;
      if (keepLength > 0) {
        final prefix = sanitized.substring(0, keepLength).replaceAll(RegExp(r'-+$'), '');
        sanitized = '$prefix-$hash';
      } else {
        sanitized = sanitized.substring(0, maxLength).replaceAll(RegExp(r'-+$'), '');
      }
    }

    return sanitized;
  }

  /// Extracts a clean browser name (e.g. chrome, firefox, safari, edge, opera)
  static String _extractBrowserName(WebBrowserInfo webInfo) {
    try {
      // 1. Try browserName enum from device_info_plus
      final name = webInfo.browserName.name.toLowerCase();
      if (name.isNotEmpty && name != 'unknown') {
        return name;
      }
    } catch (_) {}

    try {
      // 2. Fallback to userAgent inspection
      final userAgent = (webInfo.userAgent ?? '').toLowerCase();
      if (userAgent.contains('edg/')) return 'edge';
      if (userAgent.contains('opr/') || userAgent.contains('opera')) return 'opera';
      if (userAgent.contains('samsungbrowser')) return 'samsung';
      if (userAgent.contains('chrome') || userAgent.contains('crios')) return 'chrome';
      if (userAgent.contains('firefox') || userAgent.contains('fxios')) return 'firefox';
      if (userAgent.contains('safari') && !userAgent.contains('chrome')) return 'safari';
    } catch (_) {}

    return 'browser';
  }

  /// Extracts a clean platform/OS name for web (e.g. mac, win, linux, ios, android)
  static String _extractPlatformName(WebBrowserInfo webInfo) {
    try {
      final platform = (webInfo.platform ?? '').toLowerCase();
      if (platform.contains('mac')) return 'mac';
      if (platform.contains('win')) return 'win';
      if (platform.contains('linux')) return 'linux';
      if (platform.contains('iphone') || platform.contains('ipad') || platform.contains('ipod')) return 'ios';
      if (platform.contains('android')) return 'android';
    } catch (_) {}

    return 'web';
  }

  /// Generates a safe, identifiable, and unique device ID for web
  /// Format: web-{browser}-{platform}-{timestamp}-{uniqueSeed}
  /// Example: web-chrome-mac-1710500000000-a1b2c3d4
  static String _generateWebDeviceId(WebBrowserInfo webInfo) {
    final browser = _extractBrowserName(webInfo);
    final platform = _extractPlatformName(webInfo);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final seed = _uuid.v4().split('-').first;

    final rawId = 'web-$browser-$platform-$timestamp-$seed';
    return sanitizeDeviceId(rawId);
  }

  static Future<String?> getCurrentPlatformId() async {
    try {
      String? deviceIdentifier;
      if (PlatformIs.android) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        const platform = MethodChannel('com.rightminddev.rmemp/secure');
        try {
          deviceIdentifier = await platform.invokeMethod('getAndroidId');
        } catch (e) {
          print("Error fetching Android ID: $e");
        }
        print("androidId -> $deviceIdentifier");
      } else if (PlatformIs.iOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceIdentifier = "${iosInfo.model}_${iosInfo.identifierForVendor}";
      } else if (PlatformIs.web) {
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        // Generate a more stable unique ID for web using localStorage
        try {
          // Check for existing ID in localStorage (v2 or legacy)
          String? existingId = html.window.localStorage['web_device_unique_id_v2'];
          if (existingId == null || existingId.isEmpty) {
            existingId = html.window.localStorage['web_device_unique_id'];
          }

          if (existingId != null && existingId.isNotEmpty && existingId != 'null') {
            // Sanitize existing ID to remove any spaces/slashes from legacy versions
            deviceIdentifier = sanitizeDeviceId(existingId);
            html.window.localStorage['web_device_unique_id_v2'] = deviceIdentifier;
          } else {
            // Generate a new clean, safe ID with browser name & platform
            deviceIdentifier = _generateWebDeviceId(webInfo);
            html.window.localStorage['web_device_unique_id_v2'] = deviceIdentifier;
          }
        } catch (e) {
          // Fallback if localStorage is not available (e.g. Incognito / strict sandbox)
          deviceIdentifier = _generateWebDeviceId(webInfo);
        }
      } else if (PlatformIs.linux) {
        LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;
        deviceIdentifier = linuxInfo.machineId;
      }

      if (deviceIdentifier == null || deviceIdentifier.isEmpty || deviceIdentifier == "null") {
        deviceIdentifier = CacheHelper.getString("deviceIdentifier");
        if (deviceIdentifier == null || deviceIdentifier.isEmpty) {
          deviceIdentifier = "device-${DateTime.now().microsecondsSinceEpoch}";
        }
      }

      // Ensure every device identifier returned across all platforms is sanitized and bounded
      deviceIdentifier = sanitizeDeviceId(deviceIdentifier);
      CacheHelper.setString(key: "deviceIdentifier", value: deviceIdentifier);
      return deviceIdentifier;
    } catch (ex) {
      String? fallbackId = CacheHelper.getString("deviceIdentifier");
      if (fallbackId == null || fallbackId.isEmpty) {
        fallbackId = CacheHelper.getString("fallback_device_id"); // Sync with dio
        if (fallbackId == null || fallbackId.isEmpty) {
          fallbackId = "fallback-${DateTime.now().millisecondsSinceEpoch}";
        }
      }
      fallbackId = sanitizeDeviceId(fallbackId);
      CacheHelper.setString(key: "deviceIdentifier", value: fallbackId);
      CacheHelper.setString(key: "fallback_device_id", value: fallbackId);
      return fallbackId;
    }
  }

  static Future<String> getDeviceBrand() async {
    if (PlatformIs.android) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.brand;
    } else if (PlatformIs.iOS) {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    } else if (PlatformIs.web) {
      try {
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        final browserName = _extractBrowserName(webInfo);
        return 'Web: $browserName';
      } catch (e) {
        return 'Web: Unknown';
      }
    }
    return 'Unknown Device Brand';
  }

  static Future<String> getOperatingSystem() async {
    if (PlatformIs.android) {
      return 'Android';
    } else if (PlatformIs.iOS) {
      return 'iOS';
    } else if (PlatformIs.web) {
      return 'Web';
    }
    return 'Unknown Operating System';
  }

  static Future<String> getOperatingSystemVersion() async {
    if (PlatformIs.android) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
    } else if (PlatformIs.iOS) {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return 'iOS ${iosInfo.systemVersion} (${iosInfo.utsname.machine})';
    } else if (PlatformIs.web) {
      try {
        return html.window.navigator.userAgent;
      } catch (e) {
        return 'Web OS Version Unknown';
      }
    }
    return 'Unknown Operating System Version';
  }

  /// called in startup of the application to set locally all device information.
  static Future<void> initializeAndSetDeviceInfo(
      {required BuildContext context}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(context, listen: false);

    try {
      String lang = "en";
      try {
        lang = context.locale.languageCode;
      } catch (e) {
        lang = CacheHelper.getString("lang") ?? "en";
      }

      String deviceId = await getCurrentPlatformId() ?? "unknown-device";
      deviceId = sanitizeDeviceId(deviceId);

      Map<String, dynamic> deviceInfoMap = {
        'operating_system': await getOperatingSystem(),
        'operating_system_version': await getOperatingSystemVersion(),
        'brand': await getDeviceBrand(),
        'language': lang,
        'device_unique_id': deviceId,
        'type': PlatformIs.getCurrentPlatformType(),
      };

      appConfigServiceProvider.deviceInformation = DeviceInfo.fromMap(deviceInfoMap);
    } catch (e) {
      print("ERROR IN initializeAndSetDeviceInfo: $e");
      String deviceId = await getCurrentPlatformId() ?? "unknown-device";
      deviceId = sanitizeDeviceId(deviceId);
      Map<String, dynamic> fallbackMap = {
        'operating_system': 'Web',
        'operating_system_version': 'Unknown',
        'brand': 'Unknown',
        'language': CacheHelper.getString("lang") ?? "en",
        'device_unique_id': deviceId,
        'type': 'Web',
      };
      appConfigServiceProvider.deviceInformation = DeviceInfo.fromMap(fallbackMap);
    }
  }
}
