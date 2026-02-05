import 'dart:convert';

import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/fingerprint/data/models/fingerprint_model.dart';
import 'package:app_test/features/fingerprint/data/repo/fingerprint_repo.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FingerprintViewModel extends ChangeNotifier {
  List<FingerPrintModel>? fingerprints;
  UserSettingsModel? userSettings;
  bool isLoading = true;
  String? errorMessage;
  List<int>? validIndexes;

  final FingerprintRepo _repo;

  FingerprintViewModel({FingerprintRepo? repo})
      : _repo = repo ?? FingerprintRepoImpl();

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
        debugPrint("Loaded fingerprints: ${AppConstants.fingerPrints}");
      }
    } else {
      debugPrint("No fingerprints found in shared preferences");
    }
  }

  Future<void> _getEmployeeFingerprints(
      {required BuildContext context, String? empId}) async {
    // get user fingerprints
    try {
      final result = await _repo.getFingerprints(context: context, empId: empId);
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


  Future<void> addFingerPrints(BuildContext context, fingerprints) async {
    debugPrint("object --> ${fingerprints}");
    isLoading = true;
    notifyListeners();

    try {
      // Send the data using repo
      final response = await _repo.addFingerPrints(
          context: context, fingerprints: fingerprints);

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
        debugPrint("object --> ${AppConstants.fingerPrints}");
        debugPrint("object --> ${filteredList}");
        notifyListeners();

        debugPrint("$filteredList");

        AlertsService.error(
          context: context,
          message: response.data['message'],
          title: AppStrings.failed.tr(),
        );
      }
    } catch (error) {
      String errorMessage;

      if (error is DioError) {
        errorMessage =
            error.response?.data['message'] ?? 'Something went wrong';
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
