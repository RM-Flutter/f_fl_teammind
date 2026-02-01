import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';

class HomeController extends ChangeNotifier {
  UserSettingsModel? userSettings;
  UserSettings2Model? userSettings2;
  GeneralSettingsModel? generalSettings;
  final ScrollController homeScrollController = ScrollController();
  bool isLoading = false;
  @override
  void dispose() {
    homeScrollController.dispose();
    super.dispose();
  }

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializeHomeScreen(BuildContext context,List? need) async {
    updateLoadingStatus(laodingValue: true);
    await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(allData: true, context: context, need: need);
    if (!context.mounted) return;
    var jsonString;
    UserSettingsModel? userSettingsModel;
    Map<String, dynamic> gCache = {};
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    var jsonString2;
    UserSettings2Model? userSettings2Model;
    Map<String, dynamic> gCache2 = {};
    jsonString2 = CacheHelper.getString("US2");
    if (jsonString2 != null && jsonString2.isNotEmpty && jsonString2 != "") {
      gCache2 = json.decode(jsonString2) as Map<String, dynamic>; // Convert String back to JSON
      // UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache2);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    userSettings2Model = UserSettings2Model.fromJson(gCache2);
    userSettings = userSettingsModel;
    userSettings2 = userSettings2Model;
    try {
      final userBirthDate = userSettings?.birthDate;
      if (userBirthDate != null) {
        var jsonString;
        Map<String, dynamic> gCache = {};
        jsonString = CacheHelper.getString("US1");
        if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
          gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
          UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        }
        userSettingsModel = UserSettingsModel.fromJson(gCache);
      }
    } catch (err, t) {
      debugPrint("error while checking on user birthday $err at :- $t");
    }
    updateLoadingStatus(laodingValue: false);
  }

}
