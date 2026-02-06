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
      return {
        'isFakeGPS': true,
        'message': 'Error checking GPS: $e',
        'blockFingerprint': true, // في حالة الخطأ، نمنع البصمة للسلامة
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

  /// دمج noteReport مع معلومات GPS verification و fake GPS check
  static Map<String, dynamic> _mergeNoteReportWithGPSVerification(
      Map<String, dynamic>? existingNoteReport,
      Map<String, dynamic>? gpsVerification,
      Map<String, dynamic>? fakeGPSCheck,
      ) {
    final merged = Map<String, dynamic>.from(existingNoteReport ?? {});

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

      // إضافة معلومات مقارنة Network Location مع GPS
      final networkComparison = fakeGPSCheck['networkLocationComparison'] as Map<String, dynamic>?;
      if (networkComparison != null) {
        merged['networkLocationComparison'] = networkComparison;

        // إذا كان Network Location مختلف عن GPS (أكثر من 300 متر)، أضف flag
        if (networkComparison['needsReview'] == true) {
          merged['suspicious'] = true;
          merged['suspiciousReasons'] = [
            ...(merged['suspiciousReasons'] as List<dynamic>? ?? []),
            networkComparison['message'] ?? 'Network Location مختلف عن GPS',
          ];
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

  // Save fingerprint to SharedPreferences for display
  static Future<void> _saveFingerprintToSharedPreferences(
      Map<String, dynamic> fingerprintData) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Initialize AppConstants.fingerPrints if null
      AppConstants.fingerPrints ??= [];

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
    final requestBody = {'fingerprints': fingerprints};
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
  }) async {

    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final formData = {
      'type': 'fp_scan',
      'data': encoded,
      'finger_day': DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now()),
    };

    // Get double check data (WiFi or Bluetooth MAC address)
    final doubleCheckData = await DeviceMacAddressService.getDoubleCheckData();
    if (doubleCheckData != null) {
      formData['double_check_type'] = doubleCheckData['double_check_type']!;
      formData['double_check_data'] = doubleCheckData['double_check_data']!;
      debugPrint('✅ Added double check data to QR fingerprint:');
      debugPrint('   double_check_type: ${doubleCheckData['double_check_type']}');
      debugPrint('   double_check_data: ${doubleCheckData['double_check_data']}');
    } else {
      debugPrint('⚠️ No double check data available (WiFi and Bluetooth not available)');
    }

    if (noteReport != null) {
      formData['note'] = jsonEncode(noteReport);
    }
    debugPrint("formData is --> $formData");
    if (await ConnectionsService.isOnline() == true) {
      //ONLINE CASE: التحقق من fake GPS أولاً
      final fakeGPSCheck = await _checkFakeGPS();

      // إذا كان GPS fake، منع البصمة
      if (fakeGPSCheck != null && fakeGPSCheck['blockFingerprint'] == true) {
        debugPrint('🚫 Fingerprint blocked due to fake GPS: ${fakeGPSCheck['message']}');
        String errorMessage;
        String errorTitle = AppStrings.failed.tr();

        if (fakeGPSCheck['isMockLocation'] == true) {
          errorMessage = AppStrings.mockLocationDetected.tr();
          errorTitle = AppStrings.fakeGPSDetected.tr();
        } else if (fakeGPSCheck['isLowAccuracy'] == true) {
          errorMessage = '${AppStrings.lowGPSAccuracy.tr()}: ${fakeGPSCheck['accuracy']?.toStringAsFixed(2) ?? 'N/A'}m';
          errorTitle = AppStrings.fakeGPSDetected.tr();
        } else {
          errorMessage = AppStrings.suspiciousGPSData.tr();
          errorTitle = AppStrings.fakeGPSDetected.tr();
        }

        // عرض رسالة للمستخدم مباشرة
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: errorMessage,
            title: errorTitle,
          );
        }

        return OperationResult<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
        );
      }

      // إضافة معلومات fake GPS check في noteReport
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, null, fakeGPSCheck);
      if (mergedNoteReport.isNotEmpty) {
        formData['note'] = jsonEncode(mergedNoteReport);
      }

      return await DioApiService().postWithFormData<Map<String, dynamic>>(
        url,
        context: context,
        formData,
        dataKey: 'data',
        files: files,
        allData: true,
      );
    } else {
      //OFFLINE CASE: التحقق من fake GPS أولاً
      final fakeGPSCheck = await _checkFakeGPS();

      // إذا كان GPS fake، منع البصمة
      if (fakeGPSCheck != null && fakeGPSCheck['blockFingerprint'] == true) {
        debugPrint('🚫 Fingerprint blocked due to fake GPS: ${fakeGPSCheck['message']}');
        String errorMessage;
        String errorTitle = AppStrings.failed.tr();

        if (fakeGPSCheck['isMockLocation'] == true) {
          errorMessage = AppStrings.mockLocationDetected.tr();
          errorTitle = AppStrings.fakeGPSDetected.tr();
        } else if (fakeGPSCheck['isLowAccuracy'] == true) {
          errorMessage = '${AppStrings.lowGPSAccuracy.tr()}: ${fakeGPSCheck['accuracy']?.toStringAsFixed(2) ?? 'N/A'}m';
          errorTitle = AppStrings.fakeGPSDetected.tr();
        } else {
          errorMessage = AppStrings.suspiciousGPSData.tr();
          errorTitle = AppStrings.fakeGPSDetected.tr();
        }

        // عرض رسالة للمستخدم مباشرة
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: errorMessage,
            title: errorTitle,
          );
        }

        return OperationResult<Map<String, dynamic>>(
          success: false,
          message: errorMessage,
        );
      }

      // التحقق من GPS timestamp كخطوة إضافية
      final gpsVerification = await _verifyGPSTimestampOffline();
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, gpsVerification, fakeGPSCheck);

      if (mergedNoteReport.isNotEmpty) {
        formData['note'] = jsonEncode(mergedNoteReport);
      }

      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(formData)
          .then((_) async {
        // Also save to SharedPreferences for display
        await _saveFingerprintToSharedPreferences(formData);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      })
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
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
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    final requestBody = {
      'type': 'fp_navigate',
      'data': '{"lat":${lat.toString()},"long":${long.toString()}}',
      'finger_day':
      DateFormat('yyyy-MM-dd', "en").format(fingerDay ?? DateTime.now()),
    };

    // مقارنة GPS مع Network Location
    final networkComparison = await LocationService.compareGPSWithNetworkLocation(
      gpsLatitude: lat,
      gpsLongitude: long,
    );

    // إنشاء fakeGPSCheck object مع نتائج المقارنة
    final fakeGPSCheck = {
      'isFakeGPS': false,
      'latitude': lat,
      'longitude': long,
      'networkLocationComparison': networkComparison,
    };

    if (await ConnectionsService.isOnline() == true) {
      // دمج noteReport مع نتائج المقارنة
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, null, fakeGPSCheck);
      if (mergedNoteReport.isNotEmpty) {
        requestBody['note'] = jsonEncode(mergedNoteReport);
      }

      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE: التحقق من GPS timestamp كخطوة إضافية
      final gpsVerification = await _verifyGPSTimestampOffline();
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, gpsVerification, fakeGPSCheck);

      if (mergedNoteReport.isNotEmpty) {
        requestBody['note'] = jsonEncode(mergedNoteReport);
      }

      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) async {
        // Also save to SharedPreferences for display
        await _saveFingerprintToSharedPreferences(requestBody);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      })
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
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
  }) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    final formData = {
      'type': 'custom_fp_navigate',
      'data': '{"lat":${lat.toString()},"long":${long.toString()}}',
      'finger_day':
      DateFormat('yyyy-MM-dd HH:mm').format(fingerDay ?? DateTime.now()),
    };

    // مقارنة GPS مع Network Location
    final networkComparison = await LocationService.compareGPSWithNetworkLocation(
      gpsLatitude: lat,
      gpsLongitude: long,
    );

    // إنشاء fakeGPSCheck object مع نتائج المقارنة
    final fakeGPSCheck = {
      'isFakeGPS': false,
      'latitude': lat,
      'longitude': long,
      'networkLocationComparison': networkComparison,
    };

    if (await ConnectionsService.isOnline() == true) {
      // دمج noteReport مع نتائج المقارنة
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(null, null, fakeGPSCheck);
      if (mergedNoteReport.isNotEmpty) {
        formData['note'] = jsonEncode(mergedNoteReport);
      }

      return await DioApiService().postWithFormData<Map<String, dynamic>>(
        url,
        context: context,
        formData,
        dataKey: 'data',
        files: files,
        allData: true,
      );
    } else {
      //OFFLINE CASE: التحقق من GPS timestamp كخطوة إضافية
      final gpsVerification = await _verifyGPSTimestampOffline();
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(null, gpsVerification, fakeGPSCheck);

      if (mergedNoteReport.isNotEmpty) {
        formData['note'] = jsonEncode(mergedNoteReport);
      }

      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(formData)
          .then((_) async {
        // Also save to SharedPreferences for display
        await _saveFingerprintToSharedPreferences(formData);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      })
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
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
        Map<String, dynamic>? noteReport}) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final requestBody = {
      'type': 'fp_bluetooth',
      'data': encoded,
      'finger_day':
      DateFormat('yyyy-MM-dd', "en").format(fingerDay ?? DateTime.now()),
    };
    if (noteReport != null) {
      requestBody['note'] = jsonEncode(noteReport);
    }
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE: التحقق من GPS timestamp كخطوة إضافية
      final gpsVerification = await _verifyGPSTimestampOffline();
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, gpsVerification, null);

      if (mergedNoteReport.isNotEmpty) {
        requestBody['note'] = jsonEncode(mergedNoteReport);
      }

      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) async {
        // Also save to SharedPreferences for display
        await _saveFingerprintToSharedPreferences(requestBody);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      })
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
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
        Map<String, dynamic>? noteReport}) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    var date = DateFormat('dd-MM-yyyy', "en").format(fingerDay ?? DateTime.now());
    String encoded = base64Encode(utf8.encode("${data}_$date"));
    final requestBody = {
      'type': 'fp_wifi',
      'data': encoded,
      'finger_day': DateFormat('yyyy-MM-dd', "en").format(fingerDay ?? DateTime.now()),
    };
    if (noteReport != null) {
      requestBody['note'] = jsonEncode(noteReport);
    }
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE: التحقق من GPS timestamp كخطوة إضافية
      final gpsVerification = await _verifyGPSTimestampOffline();
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, gpsVerification, null);

      if (mergedNoteReport.isNotEmpty) {
        requestBody['note'] = jsonEncode(mergedNoteReport);
      }

      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) async {
        // Also save to SharedPreferences for display
        await _saveFingerprintToSharedPreferences(requestBody);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      })
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
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
        Map<String, dynamic>? noteReport}) async {
    final url = EndpointServices.getApiEndpoint(EndpointsNames.fingerprint).url;
    final requestBody = {
      'type': 'fp_nfc',
      'data': data,
      'finger_day':
      DateFormat('yyyy-MM-dd HH:mm').format(fingerDay ?? DateTime.now()),
    };
    if (noteReport != null) {
      requestBody['note'] = jsonEncode(noteReport);
    }
    if (await ConnectionsService.isOnline() == true) {
      return await DioApiService().postWithFormData<Map<String, dynamic>>(
          url, requestBody,
          context: context, dataKey: 'data', allData: true, files: files);
    } else {
      //OFFLINE CASE: التحقق من GPS timestamp كخطوة إضافية
      final gpsVerification = await _verifyGPSTimestampOffline();
      final mergedNoteReport = _mergeNoteReportWithGPSVerification(noteReport, gpsVerification, null);

      if (mergedNoteReport.isNotEmpty) {
        requestBody['note'] = jsonEncode(mergedNoteReport);
      }

      //OFFLINE CASE:SAVE FINGERPRINT TO LOCAL DB
      return await DBHiveService.saveFingerprint(requestBody)
          .then((_) async {
        // Also save to SharedPreferences for display
        await _saveFingerprintToSharedPreferences(requestBody);
        return OperationResult<Map<String, dynamic>>(
            success: true,
            message: 'Fingerprint Saved successfully in Locale Storage');
      })
          .catchError((err, t) => OperationResult<Map<String, dynamic>>(
          success: false,
          message: 'Failed to save fingerprint in Locale Storage'));
    }
  }
}
