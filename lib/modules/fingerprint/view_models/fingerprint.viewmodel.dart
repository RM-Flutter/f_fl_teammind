import 'dart:convert';

import 'package:dio/dio.dart';
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
  List<FingerPrintModel>? fingerprints;
  UserSettingsModel? userSettings;
  bool isLoading = true;
  String? errorMessage;
  List<int>? validIndexes;
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
        // 👇 احفظ الإندكسات الصحيحة هنا
        List<int> validIndexes = response.data['errors'].keys.map((k) {
          return int.tryParse(k.replaceAll(".", ""));
        }).whereType<int>().toList();

        List<Map<String, dynamic>> filteredList = [];
        for (int i = 0; i < AppConstants.fingerPrints!.length; i++) {
          if (validIndexes.contains(i)) {
            filteredList.add(AppConstants.fingerPrints![i]);
          }
        }
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fingerPrints', jsonEncode(filteredList));
        AppConstants.fingerPrints = filteredList;
        print("object --> ${AppConstants.fingerPrints}");
        print("object --> ${filteredList}");
        notifyListeners();

        print(filteredList);

        AlertsService.error(
          context: context,
          message: response.data['message'],
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

      // Add note if provided
      if (fingerprint['note'] != null || fingerprint['noteReport'] != null) {
        final noteValue = fingerprint['note'] ?? fingerprint['noteReport'];
        if (noteValue is String) {
          formData.fields.add(MapEntry('fingerprints[$i][note]', noteValue));
        } else {
          formData.fields.add(MapEntry('fingerprints[$i][note]', jsonEncode(noteValue)));
        }
      }

      // Files
      if (fingerprint['files'] != null) {
        // Decode if it's a JSON string
        var filesList = fingerprint['files'];
        if (filesList is String) {
          filesList = jsonDecode(filesList);
        }

        for (var file in filesList) {
          final fileBytes = base64Decode(file['bytes']);
          final fileName = file['fileName'];
          final mimeType = file['mimeType'] ?? 'application/octet-stream';

          final multipartFile = MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
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
