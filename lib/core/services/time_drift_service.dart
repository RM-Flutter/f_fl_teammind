import 'dart:io';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/services/connections_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class TimeDriftService {
  /// أقصى فارق توقيت مسموح به بالثواني قبل اعتباره انحرافاً (افتراضي: 60 ثانية)
  static const int defaultThresholdSeconds = 60;

  /// فحص فارق توقيت الجهاز مقارنة بالخادم المرجعي (Time Drift)
  /// يرجع:
  /// {
  ///   'isDrifted': bool,
  ///   'drift_seconds': int,
  ///   'device_time': String,
  ///   'server_time': String?,
  ///   'threshold_seconds': int,
  ///   'message': String,
  ///   'detected_at': String,
  /// }
  static Future<Map<String, dynamic>> checkTimeDrift({
    int thresholdSeconds = defaultThresholdSeconds,
  }) async {
    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    // في وضع الأوفلاين لا يتم احتساب انحراف الوقت لعدم وجود مرجع خارجي
    final isOnline = await ConnectionsService.isOnline();
    if (!isOnline) {
      return {
        'isDrifted': false,
        'drift_seconds': 0,
        'device_time': nowIso,
        'server_time': null,
        'threshold_seconds': thresholdSeconds,
        'message': 'Device is offline; time drift check skipped',
        'detected_at': nowIso,
      };
    }

    try {
      DateTime? serverTime;

      // 1) محاولة جلب التوقيت عبر HTTP Date Header من الـ baseUrl أو سيرفر موثوق
      final endpointsToTry = [
        AppConstants.baseUrl,
        'https://www.google.com',
        'https://1.1.1.1',
      ];

      for (final endpoint in endpointsToTry) {
        try {
          final uri = Uri.parse(endpoint);
          final client = http.Client();
          final request = http.Request('HEAD', uri)
            ..followRedirects = true
            ..maxRedirects = 3;

          final streamedResponse = await client
              .send(request)
              .timeout(const Duration(seconds: 4));

          final dateHeader = streamedResponse.headers['date'];
          client.close();

          if (dateHeader != null && dateHeader.isNotEmpty) {
            try {
              serverTime = HttpDate.parse(dateHeader);
              break;
            } catch (_) {
              // try next
            }
          }
        } catch (_) {
          // جرب السيرفر التالي
        }
      }

      if (serverTime == null) {
        return {
          'isDrifted': false,
          'drift_seconds': 0,
          'device_time': nowIso,
          'server_time': null,
          'threshold_seconds': thresholdSeconds,
          'message': 'Could not obtain network reference time',
          'detected_at': nowIso,
        };
      }

      final driftMillis = (now.toUtc().millisecondsSinceEpoch -
              serverTime.toUtc().millisecondsSinceEpoch)
          .abs();
      final driftSeconds = driftMillis ~/ 1000;
      final isDrifted = driftSeconds > thresholdSeconds;

      return {
        'isDrifted': isDrifted,
        'drift_seconds': driftSeconds,
        'device_time': nowIso,
        'server_time': serverTime.toIso8601String(),
        'threshold_seconds': thresholdSeconds,
        'message': isDrifted
            ? 'Time drift detected: $driftSeconds seconds difference (threshold: ${thresholdSeconds}s)'
            : 'Device time is synchronized (drift: ${driftSeconds}s)',
        'detected_at': nowIso,
      };
    } catch (e) {
      debugPrint('⚠️ Error verifying time drift: $e');
      return {
        'isDrifted': false,
        'drift_seconds': 0,
        'device_time': nowIso,
        'server_time': null,
        'threshold_seconds': thresholdSeconds,
        'message': 'Error checking time drift: $e',
        'detected_at': nowIso,
      };
    }
  }
}
