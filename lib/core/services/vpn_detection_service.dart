import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

abstract class VpnDetectionService {
  static final RegExp _vpnInterfacePattern = RegExp(
    r'^(tun|tap|ppp|p2p|ipsec|utun|wg|wireguard|xfrm|vpn)',
    caseSensitive: false,
  );

  /// كشف اتصال الـ VPN عبر Connectivity + NetworkInterfaces
  /// يرجع:
  /// {
  ///   'isVpnActive': bool,
  ///   'interface': String?,
  ///   'message': String,
  ///   'detected_at': String,
  /// }
  static Future<Map<String, dynamic>> checkVpn() async {
    final nowIso = DateTime.now().toIso8601String();

    if (kIsWeb) {
      return {
        'isVpnActive': false,
        'interface': null,
        'message': 'VPN detection not supported on web',
        'detected_at': nowIso,
      };
    }

    try {
      // 1) فحص عبر ConnectivityPlus
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.vpn)) {
        return {
          'isVpnActive': true,
          'interface': 'connectivity_vpn',
          'message': 'VPN active detected via Connectivity',
          'detected_at': nowIso,
        };
      }

      // 2) فحص عبر NetworkInterface (يدعم Android و iOS و macOS و Windows و Linux)
      try {
        final interfaces = await NetworkInterface.list(
          includeLoopback: false,
          type: InternetAddressType.any,
        );

        for (final iface in interfaces) {
          final name = iface.name.toLowerCase().trim();
          if (_vpnInterfacePattern.hasMatch(name)) {
            return {
              'isVpnActive': true,
              'interface': iface.name,
              'message': 'VPN active detected via interface ${iface.name}',
              'detected_at': nowIso,
            };
          }
        }
      } catch (e) {
        debugPrint('⚠️ NetworkInterface.list error: $e');
      }

      return {
        'isVpnActive': false,
        'interface': null,
        'message': 'No VPN connection detected',
        'detected_at': nowIso,
      };
    } catch (e) {
      debugPrint('⚠️ Error checking VPN: $e');
      return {
        'isVpnActive': false,
        'interface': null,
        'message': 'Error checking VPN: $e',
        'detected_at': nowIso,
      };
    }
  }
}
