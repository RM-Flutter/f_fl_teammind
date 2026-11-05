import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio_api_service.dart';
import 'package:app_test/core/services/backend_services/get_endpoint_service.dart';
import 'package:app_test/core/services/connections_service.dart';
import 'package:app_test/core/services/db_hive_service.dart';
import 'package:app_test/core/models/endpoint_model.dart';
import 'package:app_test/core/models/operation_result.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import 'alert_service/alerts_service.dart';
import 'device_mac_address_service.dart';
import 'fingerprint_security_runner.dart';
import 'location_service.dart';

enum Order { asc, desc }

abstract class FingerprintService {
  /// التحقق من fake GPS و mock location
  /// Returns true if GPS is fake/mock and fingerprint should be blocked
  static Future<Map<String, dynamic>?> _checkFakeGPS() async {
    try {
      final fakeGPSCheck = await LocationService.checkFakeGPS();

      if (fakeGPSCheck['isFakeGPS'] == true) {
        debugPrint('🚫 Fake GPS detected: ${fakeGPSCheck['message']}');

        return {
          'isFakeGPS': true,
          'isMockLocation': fakeGPSCheck['isMockLocation'] ?? false,
          'isLowAccuracy': fakeGPSCheck['isLowAccuracy'] ?? false,
          'isSuspiciousSpeed': fakeGPSCheck['isSuspiciousSpeed'] ?? false,
          'isSuspiciousAltitude': fakeGPSCheck['isSuspiciousAltitude'] ?? false,
          'accuracy': fakeGPSCheck['accuracy'],
          'speed': fakeGPSCheck['speed'],
          'altitude': fakeGPSCheck['altitude'],
          'latitude': fakeGPSCheck['latitude'],
          'longitude': fakeGPSCheck['longitude'],
          'message': fakeGPSCheck['message'] ?? 'Fake GPS detected',
          'blockFingerprint': true, // منع البصمة
        };
      }

      // GPS صحيح - مقارنة مع Network Location
      final gpsLat = fakeGPSCheck['latitude'] as double?;
      final gpsLon = fakeGPSCheck['longitude'] as double?;

      Map<String, dynamic>? networkComparison;
      if (gpsLat != null && gpsLon != null) {
        networkComparison = await LocationService.compareGPSWithNetworkLocation(
          gpsLatitude: gpsLat,
          gpsLongitude: gpsLon,
        );
      }

      return {
        'isFakeGPS': false,
        'isMockLocation': false,
        'latitude': fakeGPSCheck['latitude'],
        'longitude': fakeGPSCheck['longitude'],
        'accuracy': fakeGPSCheck['accuracy'],
        'message': 'GPS location is genuine',
        'blockFingerprint': false,
        'networkLocationComparison': networkComparison,
      };
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error checking fake GPS: $e');
      debugPrint('Stack trace: $stackTrace');
      // في حالة الخطأ، من الأفضل عدم منع البصمة ولكن تسجيل الشك فقط
      return {
        'isFakeGPS': false,
        'message': 'Error checking GPS: $e',
        'blockFingerprint': false,
      };
    }
  }

  /// التحقق من توقيت GPS عند عدم وجود إنترنت
  /// إذا كان الفارق بين توقيت الجهاز وتوقيت GPS أكبر من دقيقتين، يتم تسجيل هذا كشك
  static Future<Map<String, dynamic>?> _verifyGPSTimestampOffline() async {
    try {
      // التحقق من صلاحيات الموقع
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

      // الحصول على GPS position مع timestamp
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // توقيت الجهاز الحالي
      final deviceTime = DateTime.now();
      // توقيت GPS (timestamp من GPS)
      final gpsTime = position.timestamp;

      // حساب الفارق بالثواني
      final difference = (deviceTime.difference(gpsTime).abs().inSeconds).abs();
      final differenceInMinutes = difference / 60.0;

      // الحصول على timezone
      final deviceTimezone = deviceTime.timeZoneOffset;
      final gpsTimezone = gpsTime.timeZoneOffset;

      // التحقق من Timezone
      final timezoneMismatch = deviceTimezone != gpsTimezone;

      // إذا كان الفارق أكبر من دقيقتين، يتم تسجيل هذا كشك
      if (differenceInMinutes > 2.0) {
        debugPrint('⚠️ GPS Time Verification Failed: Device time difference is ${differenceInMinutes.toStringAsFixed(2)} minutes');

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
          'verificationMessage': 'Time difference between device and GPS is ${differenceInMinutes.toStringAsFixed(2)} minutes (threshold: 2 minutes)',
        };
      }

      // إذا كان هناك mismatch في timezone، يتم تسجيله أيضاً
      if (timezoneMismatch) {
        debugPrint('⚠️ Timezone mismatch detected: Device=${deviceTimezone}, GPS=${gpsTimezone}');

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
          'verificationMessage': 'Timezone mismatch detected between device and GPS',
        };
      }

      // كل شيء طبيعي
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


  /// Builds the `suspicion_flags` payload the backend scores
  /// (SuspicionScoringService / FingerprintSecurityService::validateRequiredSecurityFlags).
  /// Keys are the security check keys; each value has `status: failed` so the backend treats it as detected.
  /// Includes failed optional device/GPS checks and failed optional face checks from the note report.
  static Map<String, Map<String, String>> _buildSuspicionFlags(
      Map<String, dynamic> failedOptionals,
      Map<String, dynamic>? noteReport,
  ) {
    final all = <String, dynamic>{
      ...failedOptionals,
      if (noteReport?['security_checks_failed'] is Map)
        ...Map<String, dynamic>.from(noteReport!['security_checks_failed'] as Map),
    };
    final flags = <String, Map<String, String>>{};
    all.forEach((key, value) {
      final message = value is Map ? value['message']?.toString() : value?.toString();
      flags[key] = {
        'status': 'failed',
        'detected': '1',
        if (message != null && message.isNotEmpty) 'message': message,
        if (value is Map && value['detected_at'] != null)
          'detected_at': value['detected_at'].toString(),
      };
    });
    return flags;
  }

  /// Adds the flags as multipart array fields (suspicion_flags[key][field]) so Laravel receives an array.
  static void _applySuspicionFlags(
      Map<String, String> form, Map<String, Map<String, String>> flags) {
    flags.forEach((key, fields) {
      fields.forEach((field, value) {
        form['suspicion_flags[$key][$field]'] = value;
      });
    });
  }

  /// Offline payload: keeps the flags as a nested map so the multi upload sends them as an array.
  static Map<String, dynamic> _withSuspicionFlags(
      Map<String, dynamic> payload, Map<String, Map<String, String>> flags) {
    if (flags.isEmpty) return payload;
    return {...payload, 'suspicion_flags': flags};
  }

  /// دمج noteReport مع معلومات GPS verification و fake GPS check وفحوصات الأمان الاختيارية الفاشلة
  static Map<String, dynamic> _mergeNoteReportWithGPSVerification(
      Map<String, dynamic>? existingNoteReport,
      Map<String, dynamic>? gpsVerification,
      Map<String, dynamic>? fakeGPSCheck, {
      Map<String, dynamic>? securityChecksFailed,
  }) {
    final merged = Map<String, dynamic>.from(existingNoteReport ?? {});

    // إضافة معلومات فحوصات الأمان الاختيارية التي فشلت
    if (securityChecksFailed != null && securityChecksFailed.isNotEmpty) {
      merged['security_checks_failed'] = securityChecksFailed;
      merged['suspicious'] = true;
      merged['suspiciousReasons'] = [
        ...(merged['suspiciousReasons'] as List<dynamic>? ?? []),
        ...securityChecksFailed.entries.map((e) {
          final val = e.value;
          final msg = (val is Map) ? (val['message'] ?? val.toString()) : val.toString();
          return '${e.key}: $msg';
        }),
      ];
    }

    // إضافة معلومات GPS verification
    if (gpsVerification != null) {
      merged['gpsTimeVerification'] = gpsVerification;

      // إذا كان هناك شك، أضف flag
      if (gpsVerification['gpsTimeVerificationSuspicious'] == true) {
        merged['suspicious'] = true;
        merged['suspiciousReasons'] = [
          ...(merged['suspiciousReasons'] as List<dynamic>? ?? []),
          gpsVerification['verificationMessage'] ?? 'GPS time verification failed',
        ];
      }
    }

    // إضافة معلومات fake GPS check
    if (fakeGPSCheck != null) {
      merged['fakeGPSCheck'] = fakeGPSCheck;

      // إذا كان GPS fake، أضف flag
      if (fakeGPSCheck['isFakeGPS'] == true) {
        merged['suspicious'] = true;
        merged['suspiciousReasons'] = [
          ...(merged['suspiciousReasons'] as List<dynamic>? ?? []),
          fakeGPSCheck['message'] ?? 'Fake GPS detected',
        ];
      }

      if (AppConstants.fingerprintVerifyGpsNetworkComparison) {
        final networkComparison = fakeGPSCheck['networkLocationComparison'] as Map<String, dynamic>?;
        if (networkComparison != null) {
          merged['networkLocationComparison'] = networkComparison;
          if (networkComparison['needsReview'] == true) {
            merged['suspicious'] = true;
            merged['suspiciousReasons'] = [
              ...(merged['suspiciousReasons'] as List<dynamic>? ?? []),
              networkComparison['message'] ?? 'Network Location مختلف عن GPS',
            ];
          }
        }
      }
    }

    return merged;
  }
  // Fetch a single fingerprint by ID
  static Future<OperationResult<Map<String, dynamic>>> getFingerprint({
    required BuildContext context,
    required String id,
  }) async {
    final url =
        '${EndpointServices.getApiEndpoint(EndpointsNames.getFingerprint).url}/$id';
    return await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: 'data',
      context: context,
      allData: true,
    );
  }

  /// Fetch all fingerprints with optional parameters
  static Future<OperationResult<Map<String, dynamic>>> getFingerprints({
    required BuildContext context,
    String? pfor,
    DateTime? from,
    DateTime? to,
    int? page,
    String? orderBy,
    Order order = Order.asc,
    String? status,
  }) async {
    final DateTime currentDate = DateTime.now();

    // Default to current date if 'to' is not provided
    final DateTime toDate = to ?? currentDate;

    // Default to 'toDate - 1 months' if 'from' is not provided
    final DateTime fromDate =
        from ?? DateTime(toDate.year, toDate.month - 1, 2);

    // Custom date formatting to 'YYYY-M-D'
    String formatDate(DateTime date) {
      return '${date.year}-${date.month}-${date.day}';
    }

    // Build the base URL
    final baseUrl =
        EndpointServices.getApiEndpoint(EndpointsNames.getFingerprints).url;

    // Build query parameters
    final Map<String, String> params = {
      if (pfor != null && pfor.isNotEmpty&& pfor != "0") 'pfor': pfor,
      // 'from': formatDate(fromDate),
      // 'to': formatDate(toDate),
      if (page != null) 'page': page.toString(),
      if (orderBy != null) 'orderby': orderBy,
      'order': order == Order.asc ? 'asc' : 'desc',
      if (status != null) 'status': status,
    };

    // Construct the final URL with query parameters
    final queryParams =
    params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final url = queryParams.isEmpty ? baseUrl : '$baseUrl?$queryParams';

    // Send the request
    final response = await DioApiService().get<Map<String, dynamic>>(
      url,
      dataKey: 'data',
      context: context,
      allData: true,
    );

    return response;
  }

  // Save fingerprint to SharedPreferences for display (including face image if available)
  static Future<void> _saveFingerprintToSharedPreferences(
      Map<String, dynamic> fingerprintData, {
        List<FilePickerResult>? files,
      }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Initialize AppConstants.fingerPrints if null
      if (AppConstants.fingerPrints == null) {
        AppConstants.fingerPrints = [];
      }

      // لو عندنا صورة (files) نحولها لـ base64 ونضيفها في الماب تحت key: 'files'
      if (files != null && files.isNotEmpty) {
        final List<Map<String, dynamic>> serializedFiles = [];

        for (var fileResult in files) {
          for (var platformFile in fileResult.files) {
            if (platformFile.bytes != null) {
              serializedFiles.add({
                'fileName': platformFile.name,
                'bytes': base64Encode(platformFile.bytes!),
              });
            }
          }
        }

        if (serializedFiles.isNotEmpty) {
          fingerprintData = {
            ...fingerprintData,
            'files': serializedFiles,
          };
        }
      }

      // Add the fingerprint to the list
      AppConstants.fingerPrints!.add(fingerprintData);

      // Save to SharedPreferences
      final String jsonString = jsonEncode(AppConstants.fingerPrints);
      await prefs.setString('fingerPrints', jsonString);

      debugPrint('Fingerprint saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving fingerprint to SharedPreferences: $e');
    }
  }

  // Upload Stored Fingerprints to Server in online mood
  static Future<void> uploadFingerprintsInOnlineMood(
      {required BuildContext context}) async {
    try {
      if (await ConnectionsService.isOnline() == false) return;
      final savedFingerprints = await DBHiveService.getSavedFingerprints();
      if (savedFingerprints.isEmpty) return;
      final result = await _addFingerprints(
          context: context, fingerprints: savedFingerprints);
      if (result.success) {
        debugPrint('Saved Fingerprints Saved Successfully');
        await DBHiveService.clearSavedFingerprints();
        return;
      } else {
        debugPrint('Failed to Save Fingerprints $result');
      }
    } catch (e, t) {
      debugPrint('Error uploading Fingerprints to Server in online mood $e $t');
    }
  }

  // Add multiple fingerprints
  static Future<OperationResult<Map<String, dynamic>>> _addFingerprints({
    required BuildContext context,
    required List<Map<String, dynamic>> fingerprints,
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    // Phone clock at upload time (UTC epoch ms) so the backend can measure time drift
    final deviceTime = '${DateTime.now().millisecondsSinceEpoch}';
    final requestBody = {
      'fingerprints': fingerprints.map((f) => {...f, 'device_time': deviceTime}).toList(),
    };
    return await DioApiService().post<Map<String, dynamic>>(
      url,
      requestBody,
      context: context,
      dataKey: 'data',
      allData: true,
    );
  }

  // Add a QR code fingerprint with form data
  static Future<OperationResult<Map<String, dynamic>>> addQRCodeFingerprint({
    required BuildContext context,
    required String data,
    DateTime? fingerDay,
    required List<FilePickerResult> files,
    Map<String, dynamic>? noteReport,
    Map<String, dynamic>? failedSecurityChecks,
  }) async {
    final bool isOnline = await ConnectionsService.isOnline() == true;

    // تشغيل فحوصات الأمان عبر FingerprintSecurityRunner
    final securityResult = await FingerprintSecurityRunner.runAllChecks(
      isOffline: !isOnline,
      initialFailedOptionals: failedSecurityChecks,
    );

    if (!securityResult.canProceed) {
      final errorMessage =
          securityResult.mandatoryFailedMessage ?? AppStrings.failed.tr();
      // the caller shows every failed mandatory check as a list (showFingerprintRejection)
      return OperationResult<Map<String, dynamic>>(
        success: false,
        message: errorMessage,
        errors: securityResult.mandatoryFailures.values.toList(),
      );
    }

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en")
        .format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final formData = {
      'type': 'fp_scan',
      'data': encoded,
      'finger_day': date,
    };

    // Backend reads suspicion_flags (array keyed by the security check key).
    final suspicionFlags = _buildSuspicionFlags(
        securityResult.failedOptionals, noteReport);
    if (isOnline) _applySuspicionFlags(formData, suspicionFlags);
    // Phone clock (UTC epoch ms) so the backend can measure time drift
    if (isOnline) formData['device_time'] = '${DateTime.now().millisecondsSinceEpoch}';
    if (AppConstants.branchesDoubleCheckLevel.isEnabled) {
      formData.addAll(await DeviceMacAddressService.getDoubleCheckData() ?? {});
    }

    // دمج noteReport مع الفحوصات الأمنية والـ GPS
    final mergedNoteReport = _mergeNoteReportWithGPSVerification(
      noteReport,
      securityResult.gpsVerification,
      securityResult.fakeGpsCheck,
      securityChecksFailed: securityResult.failedOptionals,
    );

    if ((AppConstants.fingerprintSendNoteReportToApi ||
            securityResult.failedOptionals.isNotEmpty) &&
        mergedNoteReport.isNotEmpty) {
      formData['note'] = jsonEncode(mergedNoteReport);
    }

    debugPrint("📤 [QR Fingerprint Payload]: $formData");
    if (isOnline) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
        url,
        context: context,
        formData,
        dataKey: 'data',
        files: files,
        allData: true,
      );
    } else {
      // OFFLINE CASE: SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(
          _withSuspicionFlags(formData, suspicionFlags)).then((_) async {
        // Also save to SharedPreferences for display (مع حفظ الصورة)
        await _saveFingerprintToSharedPreferences(
            _withSuspicionFlags(formData, suspicionFlags), files: files);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      }).catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a GPS fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addGPSFingerprint({
    required BuildContext context,
    required String type,
    DateTime? fingerDay,
    required double lat,
    required double long,
    required List<FilePickerResult> files,
    Map<String, dynamic>? noteReport,
    Map<String, dynamic>? failedSecurityChecks,
  }) async {
    final bool isOnline = await ConnectionsService.isOnline() == true;

    final securityResult = await FingerprintSecurityRunner.runAllChecks(
      latitude: lat,
      longitude: long,
      isOffline: !isOnline,
      initialFailedOptionals: failedSecurityChecks,
    );

    if (!securityResult.canProceed) {
      final errorMessage =
          securityResult.mandatoryFailedMessage ?? AppStrings.failed.tr();
      // the caller shows every failed mandatory check as a list (showFingerprintRejection)
      return OperationResult<Map<String, dynamic>>(
        success: false,
        message: errorMessage,
        errors: securityResult.mandatoryFailures.values.toList(),
      );
    }

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en")
        .format(fingerDay ?? DateTime.now());
    final requestBody = {
      'type': 'fp_navigate',
      'data': '{"lat":${lat.toString()},"long":${long.toString()}}',
      'finger_day': date,
    };

    // Backend reads suspicion_flags (array keyed by the security check key).
    final suspicionFlags = _buildSuspicionFlags(
        securityResult.failedOptionals, noteReport);
    if (isOnline) _applySuspicionFlags(requestBody, suspicionFlags);
    // Phone clock (UTC epoch ms) so the backend can measure time drift
    if (isOnline) requestBody['device_time'] = '${DateTime.now().millisecondsSinceEpoch}';
    if (AppConstants.branchesDoubleCheckLevel.isEnabled) {
      requestBody.addAll(await DeviceMacAddressService.getDoubleCheckData() ?? {});
    }

    final mergedNoteReport = _mergeNoteReportWithGPSVerification(
      noteReport,
      securityResult.gpsVerification,
      securityResult.fakeGpsCheck,
      securityChecksFailed: securityResult.failedOptionals,
    );

    if ((AppConstants.fingerprintSendNoteReportToApi ||
            securityResult.failedOptionals.isNotEmpty) &&
        mergedNoteReport.isNotEmpty) {
      requestBody['note'] = jsonEncode(mergedNoteReport);
    }

    debugPrint("📤 [GPS Fingerprint Payload]: $requestBody");

    if (isOnline) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      return await DBHiveService.saveFingerprint(
          _withSuspicionFlags(requestBody, suspicionFlags)).then((_) async {
        await _saveFingerprintToSharedPreferences(
            _withSuspicionFlags(requestBody, suspicionFlags), files: files);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      }).catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a custom GPS fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addCustomGPSFingerprint({
    required BuildContext context,
    required String type,
    required Map<String, dynamic> data,
    DateTime? fingerDay,
    required List<FilePickerResult> files,
    required double lat,
    required double long,
    Map<String, dynamic>? noteReport,
    Map<String, dynamic>? failedSecurityChecks,
  }) async {
    final bool isOnline = await ConnectionsService.isOnline() == true;

    final securityResult = await FingerprintSecurityRunner.runAllChecks(
      latitude: lat,
      longitude: long,
      isOffline: !isOnline,
      initialFailedOptionals: failedSecurityChecks,
    );

    if (!securityResult.canProceed) {
      final errorMessage =
          securityResult.mandatoryFailedMessage ?? AppStrings.failed.tr();
      // the caller shows every failed mandatory check as a list (showFingerprintRejection)
      return OperationResult<Map<String, dynamic>>(
        success: false,
        message: errorMessage,
        errors: securityResult.mandatoryFailures.values.toList(),
      );
    }

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en")
        .format(fingerDay ?? DateTime.now());
    final formData = {
      'type': 'custom_fp_navigate',
      'data': '{"lat":${lat.toString()},"long":${long.toString()}}',
      'finger_day': date,
    };

    // Backend reads suspicion_flags (array keyed by the security check key).
    final suspicionFlags = _buildSuspicionFlags(
        securityResult.failedOptionals, noteReport);
    if (isOnline) _applySuspicionFlags(formData, suspicionFlags);
    // Phone clock (UTC epoch ms) so the backend can measure time drift
    if (isOnline) formData['device_time'] = '${DateTime.now().millisecondsSinceEpoch}';
    if (AppConstants.branchesDoubleCheckLevel.isEnabled) {
      formData.addAll(await DeviceMacAddressService.getDoubleCheckData() ?? {});
    }

    final mergedNoteReport = _mergeNoteReportWithGPSVerification(
      noteReport,
      securityResult.gpsVerification,
      securityResult.fakeGpsCheck,
      securityChecksFailed: securityResult.failedOptionals,
    );

    if (AppConstants.fingerprintSendNoteReportToApi &&
        mergedNoteReport.isNotEmpty) {
      formData['note'] = jsonEncode(mergedNoteReport);
    }

    if (isOnline) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
        url,
        context: context,
        formData,
        dataKey: 'data',
        files: files,
        allData: true,
      );
    } else {
      return await DBHiveService.saveFingerprint(
          _withSuspicionFlags(formData, suspicionFlags)).then((_) async {
        await _saveFingerprintToSharedPreferences(
            _withSuspicionFlags(formData, suspicionFlags), files: files);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      }).catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a Bluetooth fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addBluetoothFingerprint(
      {required BuildContext context,
        required String data,
        DateTime? fingerDay,
        required List<FilePickerResult> files,
        Map<String, dynamic>? noteReport,
        Map<String, dynamic>? failedSecurityChecks}) async {
    final bool isOnline = await ConnectionsService.isOnline() == true;

    final securityResult = await FingerprintSecurityRunner.runAllChecks(
      isOffline: !isOnline,
      initialFailedOptionals: failedSecurityChecks,
    );

    if (!securityResult.canProceed) {
      final errorMessage =
          securityResult.mandatoryFailedMessage ?? AppStrings.failed.tr();
      // the caller shows every failed mandatory check as a list (showFingerprintRejection)
      return OperationResult<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          errors: securityResult.mandatoryFailures.values.toList());
    }

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en")
        .format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final requestBody = {
      'type': 'fp_bluetooth',
      'data': encoded,
      'finger_day': date,
    };

    // Backend reads suspicion_flags (array keyed by the security check key).
    final suspicionFlags = _buildSuspicionFlags(
        securityResult.failedOptionals, noteReport);
    if (isOnline) _applySuspicionFlags(requestBody, suspicionFlags);
    // Phone clock (UTC epoch ms) so the backend can measure time drift
    if (isOnline) requestBody['device_time'] = '${DateTime.now().millisecondsSinceEpoch}';
    if (AppConstants.branchesDoubleCheckLevel.isEnabled) {
      requestBody.addAll(await DeviceMacAddressService.getDoubleCheckData() ?? {});
    }

    final mergedNoteReport = _mergeNoteReportWithGPSVerification(
      noteReport,
      securityResult.gpsVerification,
      securityResult.fakeGpsCheck,
      securityChecksFailed: securityResult.failedOptionals,
    );

    if ((AppConstants.fingerprintSendNoteReportToApi ||
            securityResult.failedOptionals.isNotEmpty) &&
        mergedNoteReport.isNotEmpty) {
      requestBody['note'] = jsonEncode(mergedNoteReport);
    }

    debugPrint("📤 [GPS Fingerprint Payload]: $requestBody");

    if (isOnline) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      return await DBHiveService.saveFingerprint(
          _withSuspicionFlags(requestBody, suspicionFlags)).then((_) async {
        await _saveFingerprintToSharedPreferences(
            _withSuspicionFlags(requestBody, suspicionFlags), files: files);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      }).catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a wifi fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addWifiFingerprint(
      {required BuildContext context,
        required String data,
        DateTime? fingerDay,
        required List<FilePickerResult> files,
        Map<String, dynamic>? noteReport,
        Map<String, dynamic>? failedSecurityChecks}) async {
    final bool isOnline = await ConnectionsService.isOnline() == true;

    final securityResult = await FingerprintSecurityRunner.runAllChecks(
      isOffline: !isOnline,
      initialFailedOptionals: failedSecurityChecks,
    );

    if (!securityResult.canProceed) {
      final errorMessage =
          securityResult.mandatoryFailedMessage ?? AppStrings.failed.tr();
      // the caller shows every failed mandatory check as a list (showFingerprintRejection)
      return OperationResult<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          errors: securityResult.mandatoryFailures.values.toList());
    }

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en")
        .format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final requestBody = {
      'type': 'fp_wifi',
      'data': encoded,
      'finger_day': date,
    };

    // Backend reads suspicion_flags (array keyed by the security check key).
    final suspicionFlags = _buildSuspicionFlags(
        securityResult.failedOptionals, noteReport);
    if (isOnline) _applySuspicionFlags(requestBody, suspicionFlags);
    // Phone clock (UTC epoch ms) so the backend can measure time drift
    if (isOnline) requestBody['device_time'] = '${DateTime.now().millisecondsSinceEpoch}';
    if (AppConstants.branchesDoubleCheckLevel.isEnabled) {
      requestBody.addAll(await DeviceMacAddressService.getDoubleCheckData() ?? {});
    }

    final mergedNoteReport = _mergeNoteReportWithGPSVerification(
      noteReport,
      securityResult.gpsVerification,
      securityResult.fakeGpsCheck,
      securityChecksFailed: securityResult.failedOptionals,
    );

    if ((AppConstants.fingerprintSendNoteReportToApi ||
            securityResult.failedOptionals.isNotEmpty) &&
        mergedNoteReport.isNotEmpty) {
      requestBody['note'] = jsonEncode(mergedNoteReport);
    }

    debugPrint("📤 [GPS Fingerprint Payload]: $requestBody");

    if (isOnline) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      return await DBHiveService.saveFingerprint(
          _withSuspicionFlags(requestBody, suspicionFlags)).then((_) async {
        await _saveFingerprintToSharedPreferences(
            _withSuspicionFlags(requestBody, suspicionFlags), files: files);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      }).catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }

  // Add a NFC fingerprint
  static Future<OperationResult<Map<String, dynamic>>> addNFCFingerprint(
      {required BuildContext context,
        required String data,
        DateTime? fingerDay,
        required List<FilePickerResult> files,
        Map<String, dynamic>? noteReport,
        Map<String, dynamic>? failedSecurityChecks}) async {
    final bool isOnline = await ConnectionsService.isOnline() == true;

    final securityResult = await FingerprintSecurityRunner.runAllChecks(
      isOffline: !isOnline,
      initialFailedOptionals: failedSecurityChecks,
    );

    if (!securityResult.canProceed) {
      final errorMessage =
          securityResult.mandatoryFailedMessage ?? AppStrings.failed.tr();
      // the caller shows every failed mandatory check as a list (showFingerprintRejection)
      return OperationResult<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
          errors: securityResult.mandatoryFailures.values.toList());
    }

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en")
        .format(fingerDay ?? DateTime.now());
    final requestBody = {
      'type': 'fp_nfc',
      'data': data,
      'finger_day': date,
    };

    // Backend reads suspicion_flags (array keyed by the security check key).
    final suspicionFlags = _buildSuspicionFlags(
        securityResult.failedOptionals, noteReport);
    if (isOnline) _applySuspicionFlags(requestBody, suspicionFlags);
    // Phone clock (UTC epoch ms) so the backend can measure time drift
    if (isOnline) requestBody['device_time'] = '${DateTime.now().millisecondsSinceEpoch}';
    if (AppConstants.branchesDoubleCheckLevel.isEnabled) {
      requestBody.addAll(await DeviceMacAddressService.getDoubleCheckData() ?? {});
    }

    final mergedNoteReport = _mergeNoteReportWithGPSVerification(
      noteReport,
      securityResult.gpsVerification,
      securityResult.fakeGpsCheck,
      securityChecksFailed: securityResult.failedOptionals,
    );

    if ((AppConstants.fingerprintSendNoteReportToApi ||
            securityResult.failedOptionals.isNotEmpty) &&
        mergedNoteReport.isNotEmpty) {
      requestBody['note'] = jsonEncode(mergedNoteReport);
    }

    debugPrint("📤 [GPS Fingerprint Payload]: $requestBody");

    if (isOnline) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      return await DBHiveService.saveFingerprint(
          _withSuspicionFlags(requestBody, suspicionFlags)).then((_) async {
        await _saveFingerprintToSharedPreferences(
            _withSuspicionFlags(requestBody, suspicionFlags), files: files);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      }).catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }
}
