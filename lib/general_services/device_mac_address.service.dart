import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../constants/app_constants.dart';

abstract class DeviceMacAddressService {
  static const MethodChannel _channel = MethodChannel('${AppConstants.appPackageName}/secure');

  /// Get WiFi local MAC address (internal MAC)
  /// Tries multiple methods: Native method, NetworkInterface, BSSID as fallback
  static Future<String?> getWifiLocalMacAddress() async {
    try {
      if (kIsWeb) {
        return null; // Web doesn't support MAC address
      }
      
      // Method 1: Try native method (reading from system files)
      try {
        final String? macAddress = await _channel.invokeMethod('getWifiLocalMacAddress');
        if (macAddress != null && macAddress.isNotEmpty && macAddress != "02:00:00:00:00:00") {
          debugPrint('📶 WiFi Local MAC Address (Native): $macAddress');
          return macAddress;
        }
      } catch (e) {
        debugPrint('⚠️ Native method failed: $e');
      }
      
      // Method 2: Try using NetworkInterface (works on some devices)
      if (Platform.isAndroid) {
        try {
          final interfaces = await NetworkInterface.list(
            type: InternetAddressType.IPv4,
            includeLinkLocal: false,
          );
          for (var interface in interfaces) {
            final name = interface.name.toLowerCase();
            if (name.startsWith('wlan') || name == 'wifi0') {
              // NetworkInterface doesn't provide MAC address directly in Dart
              // We'll skip this method and use BSSID instead
              debugPrint('📶 Found WiFi interface: $name');
            }
          }
        } catch (e) {
          debugPrint('⚠️ NetworkInterface method failed: $e');
        }
      }
      
      // Method 3: Use BSSID as fallback (MAC address of connected router, not device)
      // Note: This is not the device's MAC address, but can be used as identifier
      try {
        final networkInfo = NetworkInfo();
        final bssid = await networkInfo.getWifiBSSID();
        if (bssid != null && bssid.isNotEmpty && bssid != 'null' && bssid != "02:00:00:00:00:00") {
          final macRegex = RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
          if (macRegex.hasMatch(bssid)) {
            debugPrint('📶 WiFi BSSID (Router MAC - used as fallback): $bssid');
            return bssid.toUpperCase();
          }
        }
      } catch (e) {
        debugPrint('⚠️ BSSID method failed: $e');
      }
      
      debugPrint('⚠️ Could not get WiFi MAC address - All methods failed');
      return null;
    } catch (e) {
      debugPrint('⚠️ Error getting WiFi MAC address: $e');
      return null;
    }
  }

  /// Get Bluetooth local MAC address (internal MAC)
  /// Tries multiple methods: Native method, Android ID as fallback
  static Future<String?> getBluetoothLocalMacAddress() async {
    try {
      if (kIsWeb) {
        return null; // Web doesn't support MAC address
      }
      
      // Method 1: Try native method (reading from system files)
      try {
        final String? macAddress = await _channel.invokeMethod('getBluetoothLocalMacAddress');
        if (macAddress != null && macAddress.isNotEmpty && macAddress != "02:00:00:00:00:00") {
          debugPrint('📱 Bluetooth Local MAC Address (Native): $macAddress');
          return macAddress;
        }
      } catch (e) {
        debugPrint('⚠️ Native method failed: $e');
      }
      
      // Method 2: Use Android ID as fallback (unique device identifier)
      // Note: This is not the actual Bluetooth MAC address, but a unique device ID
      if (Platform.isAndroid) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;
          final androidId = androidInfo.id;
          if (androidId.isNotEmpty) {
            debugPrint('📱 Using Android ID as Bluetooth identifier (fallback): $androidId');
            return androidId.toUpperCase();
          }
        } catch (e) {
          debugPrint('⚠️ Android ID method failed: $e');
        }
      }
      
      debugPrint('⚠️ Could not get Bluetooth MAC address - All methods failed');
      return null;
    } catch (e) {
      debugPrint('⚠️ Error getting Bluetooth MAC address: $e');
      return null;
    }
  }

  /// Check if WiFi is connected
  static Future<bool> isWifiConnected() async {
    try {
      if (kIsWeb) {
        return false; // Web doesn't support this check
      }
      final bool isConnected = await _channel.invokeMethod('isWifiConnected') ?? false;
      debugPrint('📶 WiFi Connected: $isConnected');
      return isConnected;
    } catch (e) {
      debugPrint('⚠️ Error checking WiFi connection: $e');
      return false;
    }
  }

  /// Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    try {
      if (kIsWeb) {
        return false; // Web doesn't support this check
      }
      final bool isEnabled = await _channel.invokeMethod('isBluetoothEnabled') ?? false;
      debugPrint('📱 Bluetooth Enabled: $isEnabled');
      return isEnabled;
    } catch (e) {
      debugPrint('⚠️ Error checking Bluetooth status: $e');
      return false;
    }
  }

  /// Get double check data for QR code fingerprint
  /// Returns a map with 'double_check_type' and 'double_check_data' or null if neither WiFi nor Bluetooth is available
  static Future<Map<String, String>?> getDoubleCheckData() async {
    try {
      // Check WiFi first (priority)
      final bool wifiConnected = await isWifiConnected();
      if (wifiConnected) {
        final String? wifiMac = await getWifiLocalMacAddress();
        if (wifiMac != null && wifiMac.isNotEmpty) {
          final date = DateFormat('dd-MM-yyyy', "en").format(DateTime.now());
          final dataToEncode = '${wifiMac}_$date';
          final encodedData = base64Encode(utf8.encode(dataToEncode));
          
          debugPrint('✅ Double Check - WiFi:');
          debugPrint('   Type: fp_wifi');
          debugPrint('   MAC Address: $wifiMac');
          debugPrint('   Date: $date');
          debugPrint('   Encoded Data: $encodedData');
          
          return {
            'double_check_type': 'fp_wifi',
            'double_check_data': encodedData,
          };
        }
      }

      // If WiFi is not available, check Bluetooth
      final bool bluetoothEnabled = await isBluetoothEnabled();
      if (bluetoothEnabled) {
        final String? bluetoothMac = await getBluetoothLocalMacAddress();
        if (bluetoothMac != null && bluetoothMac.isNotEmpty) {
          final date = DateFormat('dd-MM-yyyy', "en").format(DateTime.now());
          final dataToEncode = '${bluetoothMac}_$date';
          final encodedData = base64Encode(utf8.encode(dataToEncode));
          
          debugPrint('✅ Double Check - Bluetooth:');
          debugPrint('   Type: fp_bluetooth');
          debugPrint('   MAC Address: $bluetoothMac');
          debugPrint('   Date: $date');
          debugPrint('   Encoded Data: $encodedData');
          
          return {
            'double_check_type': 'fp_bluetooth',
            'double_check_data': encodedData,
          };
        }
      }

      // Neither WiFi nor Bluetooth is available
      debugPrint('⚠️ Double Check: Neither WiFi nor Bluetooth is available');
      return null;
    } catch (e) {
      debugPrint('⚠️ Error getting double check data: $e');
      return null;
    }
  }
}

