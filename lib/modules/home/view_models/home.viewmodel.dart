import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/alert_service/alerts.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/models/all_company_request.model.dart';
import 'package:rmemp/models/myteam_request.model.dart';
import 'package:rmemp/models/other_department_request.model.dart';
import 'package:rmemp/modules/more/views/contactus/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/birthday_checker.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/notification.model.dart';
import '../../../models/request.model.dart';
import '../../../models/settings/general_settings.model.dart';
import '../../../models/settings/user_settings.model.dart';
import '../../../models/settings/user_settings_2.model.dart';
import '../../../routing/app_router.dart';
import '../../../services/crud_operation.service.dart';
import '../../../services/requests.services.dart';

class HomeViewModel extends ChangeNotifier {
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
  var errorMessage;
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
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    // if (appConfigServiceProvider.isLogin != true ||
    //     appConfigServiceProvider.token.isEmpty) {
    //  return null;
    // }
    // initialize [userSettings] and [userSettings2] after chackings about token
    await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(
        allData: true, context: context, need: need);
    if (!context.mounted) return;
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
        UserSettingsModel userSettingsModel;
        var gCache;
        jsonString = CacheHelper.getString("US1");
        if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
          gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
          UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        }
        userSettingsModel = UserSettingsModel.fromJson(gCache);
        // BirthdayChecker.checkBirthday(
        //     context: context,
        //     birthDate: userSettingsModel.birthDate);
      }
    } catch (err, t) {
      debugPrint("error while checking on user birthday $err at :- $t");
    }
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> _getAllUserRequests(BuildContext context) async {
    // get my Requests (all users)
    try {
      final result =
          (await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
              page: 1, context: context, reqType: GetRequestsTypes.mine));
      if (result.success &&
          result.data != null &&
          result.data?.isNotEmpty == true) {
        var requestsData = result.data?['requests'] as List<dynamic>?;
        myRequests = requestsData?.map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
        var prefs = await SharedPreferences.getInstance();
        final jsonString = json.encode(result.data); // Convert JSON to String
        await prefs.setString("mRequest", jsonString);
      }
    } catch (err, t) {
      debugPrint("error while getting my requests ${err.toString()} at :- $t");
    }

    // get team request and other department requests if i manager (Manager || team leader)
    if ((userSettings?.isManagerIn != null &&
            (userSettings?.isManagerIn?.isNotEmpty ?? false)) ||
        (userSettings?.isTeamleaderIn != null &&
            (userSettings?.isTeamleaderIn?.isNotEmpty ?? false))) {
      // get my Team Requests
      try {
        final result =
            (await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
                context: context, reqType: GetRequestsTypes.myTeam, page: 1));
        if (result.success &&
            result.data != null &&
            result.data?.isNotEmpty == true) {
          var requestsData = result.data?['requests'] as List<dynamic>?;
          myTeamRequests = requestsData
              ?.map(
                  (item) => MyTeamRequestModel.fromJson(item as Map<String, dynamic>))
              .toList();
          notifyListeners();
          var prefs = await SharedPreferences.getInstance();
          final jsonString = json.encode(result.data); // Convert JSON to String
          await prefs.setString("mtRequest", jsonString);
        }
      } catch (err, t) {
        debugPrint(
            "error while getting my Team requests ${err.toString()} at :- $t");
      }
      // get other Department Requests
      try {
        final result =
            (await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
                context: context,
                reqType: GetRequestsTypes.otherDepartment,
                page: 1));
        if (result.success &&
            result.data != null &&
            result.data?.isNotEmpty == true) {
          var requestsData = result.data?['requests'] as List<dynamic>?;
          otherDepartmentRequests = requestsData
              ?.map(
                  (item) => OtherDepartmentRequestModel.fromJson(item as Map<String, dynamic>))
              .toList();
          var prefs = await SharedPreferences.getInstance();
          final jsonString = json.encode(result.data); // Convert JSON to String
          await prefs.setString("odRequest", jsonString);
          notifyListeners();
        }
      } catch (err, t) {
        debugPrint(
            "error while getting other Departments requests ${err.toString()} at :- $t");
      }
    }

    // get all Company Requests
    if (userSettings?.topManagement == true) {
      try {
        final result =
            (await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
                context: context, reqType: GetRequestsTypes.allCompany));
        if (result.success &&
            result.data != null &&
            result.data?.isNotEmpty == true) {
          var requestsData = result.data?['requests'] as List<dynamic>?;
          allCompanyRequests = requestsData
              ?.map(
                  (item) => AllCompanyRequestModel.fromJson(item as Map<String, dynamic>))
              .toList();
          var prefs = await SharedPreferences.getInstance();
          final jsonString = json.encode(result.data); // Convert JSON to String
          await prefs.setString("acRequest", jsonString);
          notifyListeners();
        }
      } catch (err, t) {
        debugPrint(
            "error while getting all company requests ${err.toString()} at :- $t");
      }
    }
    notifyListeners();
  }
  getHome(context)async{
    notifyListeners();
    isLoading = true;
    DioHelper.getData(
        url: "/emp_requests/v1/home",
      context: context,
    ).then((value)async{
      if(value.data['status'] == true){
        var prefs = await SharedPreferences.getInstance();
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
      isLoading = false;
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
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
