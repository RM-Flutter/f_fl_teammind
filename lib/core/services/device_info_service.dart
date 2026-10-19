import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/device_information.model.dart';
import '../platform/platform_is.dart';
import 'app_config_service.dart';
import 'dart:html' if (dart.library.io) 'dart_html_stub.dart' as html;

import 'backend_services/api_service/dio_api_service/shared.dart';





abstract class DeviceInformationService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
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
          // Try to get or create a persistent device ID from localStorage
          final existingId = html.window.localStorage['web_device_unique_id_v2'];
          if (existingId != null && existingId.isNotEmpty) {
            deviceIdentifier = existingId;
          } else {
            // Generate a new ID based on browser fingerprint
            deviceIdentifier = "web_${DateTime.now().millisecondsSinceEpoch}_${webInfo.hardwareConcurrency ?? 0}";
            // Store it in localStorage for persistence
            html.window.localStorage['web_device_unique_id_v2'] = deviceIdentifier;
          }
        } catch (e) {
          // Fallback if localStorage is not available
          deviceIdentifier = "web_fallback_${DateTime.now().millisecondsSinceEpoch}";
        }
      } else if (PlatformIs.linux) {
        LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;
        deviceIdentifier = linuxInfo.machineId;
      }

      if (deviceIdentifier == null || deviceIdentifier.isEmpty || deviceIdentifier == "null") {
        deviceIdentifier = CacheHelper.getString("deviceIdentifier");
        if (deviceIdentifier == null || deviceIdentifier.isEmpty) {
          deviceIdentifier = DateTime.now().microsecondsSinceEpoch.toString();
          CacheHelper.setString(key: "deviceIdentifier", value: deviceIdentifier);
        }
      }
      return deviceIdentifier;
    } catch (ex) {
      String? fallbackId = CacheHelper.getString("deviceIdentifier");
      if (fallbackId == null || fallbackId.isEmpty) {
        fallbackId = CacheHelper.getString("fallback_device_id"); // Sync with dio
        if (fallbackId == null || fallbackId.isEmpty) {
          fallbackId = "fallback_${DateTime.now().millisecondsSinceEpoch}";
        }
        CacheHelper.setString(key: "deviceIdentifier", value: fallbackId);
        CacheHelper.setString(key: "fallback_device_id", value: fallbackId);
      }
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
        return 'Web: ${webInfo.userAgent}';
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

      String deviceId = await getCurrentPlatformId() ?? "Unknown Device";

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
      String deviceId = await getCurrentPlatformId() ?? "Unknown Device";
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
