import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/alert_service/alerts.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/fingerprint.model.dart';
import '../../../models/settings/user_settings.model.dart';
import '../../../services/fingerprint_service.dart';

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
  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializeFingerprintScreen(
      {required BuildContext context, String? empId}) async {
    updateLoadingStatus(laodingValue: true);
    var jsonString;
    UserSettingsModel? userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    userSettings = userSettingsModel;
    await _getEmployeeFingerprints(context: context, empId: empId);
    await loadFingerprintsFromPreferences();
    updateLoadingStatus(laodingValue: false);
  }
  Future<void> loadFingerprintsFromPreferences() async {
    isLoading = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('fingerPrints')) {
      final String? jsonString = prefs.getString('fingerPrints');
      if (jsonString != null) {
        // Decode the JSON string back to a list of objects
        final List<dynamic> decodedList = jsonDecode(jsonString);
        AppConstants.fingerPrints = decodedList.cast<Map<String, dynamic>>();
        isLoading = false;
        notifyListeners();
        print("Loaded fingerprints: ${AppConstants.fingerPrints}");
      }
    } else {
      print("No fingerprints found in shared preferences");
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
    print("object --> ${fingerprints}");
    isLoading = true;
    notifyListeners();
    // Prepare the data as JSON without base64 encoding files
    final fingerprintData = await prepareFingerprintData(fingerprints);
    FormData formData = await buildFormData(fingerprints);

    try {

      // Send the data as multipart/form-data
      final response = await DioHelper.postFormData(
        context: context,
        url: "/rm_fingerprint/v1/add_fingerprints",
        formdata: formData
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
        List<int> validIndexes = [];
        final List<String> errorMessages = [];

        if (errors is Map) {
          // نستخرج الإندكسات من الـ keys ونجمّع رسائل الأخطاء من الـ values
          errors.forEach((key, value) {
            final index =
                int.tryParse(key.toString().replaceAll('.', ''));
            if (index != null) {
              validIndexes.add(index);
            }

            if (value is List) {
              errorMessages.addAll(
                  value.map((e) => e.toString()));
            } else if (value != null) {
              errorMessages.add(value.toString());
            }
          });
        } else if (errors is List) {
          // صيغة قائمة رسائل فقط
          errorMessages
              .addAll(errors.map((e) => e.toString()));
        } else if (errors != null) {
          // أي قيمة أخرى قابلة للتحويل لنص
          errorMessages.add(errors.toString());
        }

        // لو عندنا إندكسات صحيحة، نحدّث قائمة البصمات المحفوظة
        if (validIndexes.isNotEmpty &&
            AppConstants.fingerPrints != null) {
          List<Map<String, dynamic>> filteredList = [];
          for (int i = 0;
              i < AppConstants.fingerPrints!.length;
              i++) {
            if (validIndexes.contains(i)) {
              filteredList.add(AppConstants.fingerPrints![i]);
            }
          }
          final SharedPreferences prefs =
              await SharedPreferences.getInstance();
          await prefs.setString(
              'fingerPrints', jsonEncode(filteredList));
          AppConstants.fingerPrints = filteredList;
          print("object --> ${AppConstants.fingerPrints}");
          print("object --> ${filteredList}");
          notifyListeners();
          print(filteredList);
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

      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
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

      // Files — ضغط الصور قبل الإرسال (أونلاين وأوفلاين) لتقليل المساحة
      if (fingerprint['files'] != null) {
        var filesList = fingerprint['files'];
        if (filesList is String) {
          filesList = jsonDecode(filesList);
        }

        for (var file in filesList) {
          Uint8List fileBytes = Uint8List.fromList(base64Decode(file['bytes']) as List<int>);
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

      if (fingerprint['files[]'] != null && fingerprint['files'].isNotEmpty) {
        List<Map<String, dynamic>> files = [];

        for (var file in fingerprint['files[]']) {
          files.add({
            'fileName': file['fileName'],
            'mimeType': file['mimeType'],
            'bytes': base64Encode(file['bytes']), // Encode as base64
          });
        }

        entry['files[]'] = files;
      }

      processed.add(entry);
    }

    return {'fingerprints': processed};
  }


}
