import 'dart:convert';
import 'dart:io';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/notifications_model.dart';
import 'package:app_test/core/models/requests_model.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.service.dart';
import 'package:app_test/features/home/data/models/all_company_requests_model.dart';
import 'package:app_test/features/home/data/models/my_team_request_model.dart';
import 'package:app_test/features/home/data/models/other_departments_request.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/settings_service.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/models/settings/user_settings_2.model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends ChangeNotifier {
  UserSettingsModel? userSettings;
  UserSettings2Model? userSettings2;
  GeneralSettingsModel? generalSettings;
  List<RequestModel>? myRequests;
  List<MyTeamRequestModel>? myTeamRequests;
  List<AllCompanyRequestModel>? allCompanyRequests;
  List<OtherDepartmentRequestModel>? otherDepartmentRequests;
  List<NotificationModel>? notifications;
  final ScrollController homeScrollController = ScrollController();
  bool isLoading = false;
  bool isSuccess = false;
  var errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    homeScrollController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializeHomeScreen(BuildContext context,List? need) async {
    if (_disposed) return;
    updateLoadingStatus(laodingValue: true);
    Provider.of<AppConfigService>(context, listen: false);
    await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(
        allData: true, context: context, need: need);
    if (_disposed || !context.mounted) return;
    var jsonString;
    UserSettingsModel? userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    var jsonString2;
    UserSettings2Model? userSettings2Model;
    var gCache2;
    jsonString2 = CacheHelper.getString("US2");
    if (jsonString2 != null && jsonString2.isNotEmpty && jsonString2 != "") {
      gCache2 = json.decode(jsonString2) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache2);
    }
    userSettingsModel = gCache != null ? UserSettingsModel.fromJson(gCache) : userSettingsModel;
    userSettings2Model = gCache2 != null ?UserSettings2Model.fromJson(gCache2) : userSettings2Model;
    userSettings = userSettingsModel;
    userSettings2 = userSettings2Model;

    // get user requests
    //  await _getUserNotification(context);
    //  await getHome(context);
    // Checking for user BirthDate
    try {
      final userBirthDate = userSettings?.birthDate;
      if (userBirthDate != null) {
        // intialize Birthday Service Checker
        var jsonString;
        var gCache;
        jsonString = CacheHelper.getString("US1");
        if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
          gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
          UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        }
        // BirthdayChecker.checkBirthday(
        //     context: context,
        //     birthDate: userSettingsModel.birthDate);
      }
      if (!_disposed) {
        isSuccess = true;
        notifyListeners();
      }
    } catch (err, t) {
      debugPrint("error while checking on user birthday $err at :- $t");
    }
    if (!_disposed) {
      updateLoadingStatus(laodingValue: false);
    }
  }

  Future<void> _preloadProfileImage(BuildContext context) async {
    try {
      // Check if online
      final isConnected = await InternetConnectionChecker.createInstance().hasConnection.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );

      if (!isConnected) {
        debugPrint('⚠️ Offline: Skipping profile image preload');
        return;
      }

      // Get profile photo URL from cache
      final jsonString = CacheHelper.getString("US1");
      if (jsonString == null || jsonString.isEmpty) {
        return;
      }

      final Map<String, dynamic> cache = json.decode(jsonString) as Map<String, dynamic>;
      final String? photoUrl = cache['photo'] as String?;

      if (photoUrl == null || photoUrl.isEmpty) {
        return;
      }

      // Check if image is already cached
      final documentDirectory = await getTemporaryDirectory();
      final fileName = Uri.parse(photoUrl).pathSegments.last;
      final cachedFile = File('${documentDirectory.path}/profile_image_$fileName');

      if (await cachedFile.exists()) {
        debugPrint('✅ Profile image already cached');
        return;
      }

      // Download and cache the image
      debugPrint('📥 Preloading profile image...');
      await MainFabServices.downloadImage(photoUrl, useCache: true);
      debugPrint('✅ Profile image preloaded and cached');
    } catch (e) {
      debugPrint('⚠️ Error preloading profile image: $e');
      // Don't show error to user, just log it
    }
  }

  getHome(context)async{
    if (_disposed) return;
    notifyListeners();
    isLoading = true;

    // Preload profile image in background (non-blocking)
    _preloadProfileImage(context);

    DioHelper.getData(
      url: "/emp_requests/v1/home",
      context: context,
    ).then((value)async{
      if(value.data['status'] == true){
        await SharedPreferences.getInstance();
        var requestsData = value.data?['my_requests'] as List<dynamic>?;
        myRequests = requestsData?.map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
        var requestsData2 = value.data?['team_requests'] as List<dynamic>?;
        myTeamRequests = requestsData2?.map((item) => MyTeamRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
        var requestsData3 = value.data?['other_departments'] as List<dynamic>?;
        otherDepartmentRequests = requestsData3?.map((item) => OtherDepartmentRequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
        // final jsonString = json.encode({value.data}); // Convert JSON to String
        // await prefs.setString("mRequest", jsonString);
        // final jsonString2 = json.encode(value.data); // Convert JSON to String
        // await prefs.setString("mtRequest", jsonString2);
        // final jsonString3 = json.encode(value.data); // Convert JSON to String
        // await prefs.setString("odRequest", jsonString3);
        var notificationData = value.data['notifications']as List<dynamic>?;
        notifications = notificationData
            ?.map((item) =>
            NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }else{
        AlertsService.error(
            context: context,
            message: value.data['message'],
            title: AppStrings.failed.tr());
      }
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }).catchError((error){
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      AlertsService.error(
          context: context,
          message: errorMessage,
          title: AppStrings.failed.tr());
    });
  }
}
