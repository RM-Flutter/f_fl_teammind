import 'dart:convert';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:flutter/material.dart';

class RequestTermsViewModel extends ChangeNotifier {
  List<RequestTypeOrList>? requestTypes;
  bool isLoading = false;
  String? errorMessage;

  Future<void> getRequestTypes({required BuildContext context}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Fetch generalSettings data from cache
      var jsonString = CacheHelper.getString("USG");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        final gCache = json.decode(jsonString) as Map<String, dynamic>;
        UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache);
      }

      // Get request types from generalSettings
      final requestsTypesDataFromGeneralSettings =
          UserSettingConst.generalSettingsModel?.requestTypes;

      if (requestsTypesDataFromGeneralSettings == null ||
          requestsTypesDataFromGeneralSettings.isEmpty) {
        requestTypes = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      // Convert Map to List
      requestTypes = requestsTypesDataFromGeneralSettings.values.toList();
      
      isLoading = false;
      notifyListeners();
    } catch (ex, t) {
      debugPrint(
          'Error getting request types ${ex.toString()} at :- ${t.toString()}');
      requestTypes = [];
      errorMessage = ex.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}

