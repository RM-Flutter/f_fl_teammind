import 'package:app_test/core/services/app_error_reporter.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/fingerprint_service.dart';
import 'package:app_test/features/fingerprint/data/models/fingerprint_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/backend_services/api_service/dio_api_service/dio.dart';


class FingerprintViewModel extends ChangeNotifier {
  /// ضغط بايتات الصورة لتقليل الحجم عند الإرسال (جودة 72)
  static Future<Uint8List> _compressImageIfNeeded(
      Uint8List bytes,
      String mimeType,
      String fileName,
      ) async {
    final isImage = mimeType.startsWith('image/') ||
        RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)$', caseSensitive: false).hasMatch(fileName);
    if (!isImage || bytes.length < 1024) return bytes;
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 1200,
        minWidth: 1200,
        quality: 72,
      );
      return compressed.isNotEmpty ? compressed : bytes;
    } catch (e) {
      debugPrint('Fingerprint image compress error: $e');
      return bytes;
    }
  }

  List<FingerPrintModel>? fingerprints;
  UserSettingsModel? userSettings;
  bool isLoading = true;
  String? errorMessage;
  List<int>? validIndexes;
  final Set<int> _deletingOfflineIndexes = {};
  void updateLoadingStatus({required bool loadingValue}) {
    isLoading = loadingValue;
    notifyListeners();
  }

  Future<void> initializeFingerprintScreen(
      {required BuildContext context, String? empId}) async {
    updateLoadingStatus(loadingValue: true);
    try {
      String? jsonString;
      Map<String, dynamic>? gCache;
      jsonString = CacheHelper.getString("US1");
      if (jsonString != null && jsonString.isNotEmpty) {
        gCache = json.decode(jsonString) as Map<String, dynamic>;
        UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        userSettings = UserSettingsModel.fromJson(gCache);
      } else {
        userSettings = null;
      }
      await _getEmployeeFingerprints(context: context, empId: empId);
      await loadFingerprintsFromPreferences();
    } catch (e) {
      debugPrint('Error initializing fingerprint screen: $e');
    } finally {
      updateLoadingStatus(loadingValue: false);
    }
  }
  Future<void> loadFingerprintsFromPreferences() async {
    isLoading = true;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('fingerPrints')) {
        final String? jsonString = prefs.getString('fingerPrints');
        if (jsonString != null && jsonString.isNotEmpty) {
          // Decode the JSON string back to a list of objects
          final List<dynamic> decodedList = jsonDecode(jsonString);
          AppConstants.fingerPrints = decodedList
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          print("Loaded fingerprints: ${AppConstants.fingerPrints}");
        } else {
          AppConstants.fingerPrints = [];
        }
      } else {
        AppConstants.fingerPrints = [];
        print("No fingerprints found in shared preferences");
      }
    } catch (e) {
      debugPrint("Error loading fingerprints from preferences: $e");
      AppConstants.fingerPrints = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// حذف بصمة أوفلاين واحدة من الكاش (SharedPreferences + AppConstants)
  Future<void> deleteOfflineFingerprintAt(int index) async {
    if (AppConstants.fingerPrints == null ||
        index < 0 ||
        index >= AppConstants.fingerPrints!.length) {
      return;
    }

    _deletingOfflineIndexes.add(index);
    notifyListeners();

    // إعطاء الفرصة لرسم اللودينج قبل تنفيذ الحذف
    await Future.delayed(const Duration(milliseconds: 100));

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    AppConstants.fingerPrints!.removeAt(index);

    if (AppConstants.fingerPrints!.isEmpty) {
      await prefs.remove('fingerPrints');
    } else {
      await prefs.setString(
        'fingerPrints',
        jsonEncode(AppConstants.fingerPrints),
      );
    }

    _deletingOfflineIndexes.remove(index);
    notifyListeners();
  }
  Set<int> get deletingOfflineIndexes => _deletingOfflineIndexes;
  Future<void> _getEmployeeFingerprints(
      {required BuildContext context, String? empId}) async {
    // get user fingerprints
    try {
      final result = await FingerprintService.getFingerprints(
          context: context, pfor: empId);
      if (result.success && result.data != null) {
        var fingerprintsData = result.data?['fingerprints'] as List<dynamic>?;
        fingerprints = fingerprintsData
            ?.map((item) =>
            FingerPrintModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (err, t) {
      debugPrint(
          "error while getting user fingerprints ${err.toString()} at :- $t");
    }
  }


  Future<void> addFingerPrints(BuildContext context,fingerprints) async {
    isLoading = true;
    notifyListeners();
    // Prepare the data as JSON without base64 encoding files
    await prepareFingerprintData(fingerprints);
    FormData formData = await buildFormData(fingerprints);

    try {

      // Send the data as multipart/form-data
      final response = await DioHelper.postFormData(
          context: context,
          url: "/rm_fingerprint/v1/add_fingerprints",
          formdata: formData,
          query: null,
          data: const {}
      );

      // Handle the response
      if (response.data['status'] == true) {
        AlertsService.success(
          context: context,
          message: response.data['message'],
          title: AppStrings.success.tr(),
        );
        // Reset the fingerprints after successful submission
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('fingerPrints');
        AppConstants.fingerPrints = [];
        Navigator.pop(context);
      } else {
        // 👇 errors من الـ API ممكن تيجي بأكثر من شكل:
        // 1) Map فيه مفاتيح تمثل الإندكسات وقيمها رسائل أخطاء
        //    "errors": { "0": "location is no founded", "1": "location is no founded" }
        // 2) List من الرسائل فقط:
        //    "errors": ["location is no founded", "location is no founded"]
        // 3) أي شكل آخر قابل للتحويل لنص واحد

        final dynamic errors = response.data['errors'];
        final List<String> errorMessages = [];

        if (errors is Map && errors.isNotEmpty) {
          // errors keyed by the index of the sent fingerprint: the server saved every other fingerprint.
          // Keep only the refused ones in the queue, each with its error shown under its card.
          final List sent = List.from(fingerprints);
          final List<Map<String, dynamic>> refused = [];
          errors.forEach((key, value) {
            final index = int.tryParse(key.toString().replaceAll('.', ''));
            if (index == null || index < 0 || index >= sent.length) return;
            final item = Map<String, dynamic>.from(sent[index] as Map);
            item['upload_error'] = value is List ? value.join(', ') : '$value';
            refused.add(item);
          });

          if (refused.isNotEmpty) {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            AppConstants.fingerPrints = refused;
            await prefs.setString('fingerPrints', jsonEncode(refused));
            notifyListeners();
          }
        } else if (errors is List) {
          errorMessages.addAll(errors.map((e) => e.toString()));
        } else if (errors != null) {
          errorMessages.add(errors.toString());
        }

        // نجهّز رسالة الخطأ للمستخدم (رسالة الـ API + كل رسائل errors)
        String baseMessage = response.data['message']?.toString() ??
            AppStrings.failed.tr();
        if (errorMessages.isNotEmpty) {
          baseMessage =
          '$baseMessage\n${errorMessages.join('\n')}';
        }

        AlertsService.error(
          context: context,
          message: baseMessage,
          title: AppStrings.failed.tr(),
        );
      }

    } catch (error) {
      String errorMessage;

      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'something_went_wrong'.tr();
      } else {
        errorMessage = AppErrorReporter.safeMessage(error);
      }

      AlertsService.error(
        context: context,
        message: errorMessage,
        title: AppStrings.failed.tr(),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<FormData> buildFormData( fingerprints) async {
    FormData formData = FormData();

    for (int i = 0; i < fingerprints.length; i++) {
      var fingerprint = fingerprints[i];

      // Basic fields
      formData.fields.addAll([
        MapEntry('fingerprints[$i][type]', fingerprint['type']),
        MapEntry('fingerprints[$i][data]', fingerprint['data']),
        MapEntry('fingerprints[$i][finger_day]', fingerprint['finger_day']),
      ]);

      // Add double_check_type and double_check_data if provided (for QR code fingerprints)
      if (fingerprint['double_check_type'] != null) {
        formData.fields.add(MapEntry('fingerprints[$i][double_check_type]', fingerprint['double_check_type']));
      }
      if (fingerprint['double_check_data'] != null) {
        formData.fields.add(MapEntry('fingerprints[$i][double_check_data]', fingerprint['double_check_data']));
      }

      // Add note if provided
      if (fingerprint['note'] != null || fingerprint['noteReport'] != null) {
        final noteValue = fingerprint['note'] ?? fingerprint['noteReport'];
        if (noteValue is String) {
          formData.fields.add(MapEntry('fingerprints[$i][note]', noteValue));
        } else {
          formData.fields.add(MapEntry('fingerprints[$i][note]', jsonEncode(noteValue)));
        }
      }

      // Phone clock at upload time (UTC epoch ms) so the backend can measure time drift
      formData.fields.add(MapEntry('fingerprints[$i][device_time]', '${DateTime.now().millisecondsSinceEpoch}'));
      // suspicion_flags (backend key) as array fields: fingerprints[i][suspicion_flags][key][field]
      var flags = fingerprint['suspicion_flags'];
      if (flags is String) {
        try {
          flags = jsonDecode(flags);
        } catch (_) {
          flags = null;
        }
      }
      if (flags is Map) {
        flags.forEach((key, value) {
          if (value is Map) {
            value.forEach((field, fieldValue) {
              if (fieldValue == null) return;
              formData.fields.add(MapEntry(
                  'fingerprints[$i][suspicion_flags][$key][$field]', fieldValue.toString()));
            });
          }
        });
      }

      // Files — ضغط الصور قبل الإرسال (أونلاين وأوفلاين) لتقليل المساحة
      if (fingerprint['files'] != null) {
        var filesList = fingerprint['files'];
        if (filesList is String) {
          filesList = jsonDecode(filesList);
        }

        for (var file in filesList) {
          Uint8List fileBytes = base64Decode(file['bytes']);
          final fileName = file['fileName'] as String? ?? 'image.jpg';
          final mimeType = file['mimeType'] as String? ?? 'application/octet-stream';

          fileBytes = await _compressImageIfNeeded(fileBytes, mimeType, fileName);

          final multipartFile = MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType.startsWith('image/') ? 'image/jpeg' : mimeType),
          );

          formData.files.add(MapEntry('fingerprints[$i][files][]', multipartFile));
        }
      }



    }

    return formData;
  }

  Future<Map<String, dynamic>> prepareFingerprintData(List fingerprints) async {
    List<Map<String, dynamic>> processed = [];

    for (var fingerprint in fingerprints) {
      Map<String, dynamic> entry = {
        'type': fingerprint['type'] ?? 'fp_scan',
        'data': fingerprint['data'],
        'finger_day': fingerprint['finger_day'],
      };

      if (fingerprint['suspicion_flags'] != null) {
        entry['suspicion_flags'] = fingerprint['suspicion_flags'];
      }

      if (fingerprint['files'] != null && fingerprint['files'].isNotEmpty) {
        List<Map<String, dynamic>> files = [];

        for (var file in fingerprint['files']) {
          final fileBytes = file['bytes'];
          files.add({
            'fileName': file['fileName'],
            'mimeType': file['mimeType'],
            'bytes': fileBytes is String ? fileBytes : base64Encode(fileBytes as List<int>), // Safe check for base64 encoding
          });
        }

        entry['files'] = files;
      }

      processed.add(entry);
    }

    return {'fingerprints': processed};
  }


}
