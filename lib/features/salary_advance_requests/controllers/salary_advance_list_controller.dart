import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/salary_advance_requests/shared/repos/salary_advance_repo.dart';

class SalaryAdvanceListController extends ChangeNotifier {
  List<SalaryAdvanceRequestModel>? personalRequests;
  List<SalaryAdvanceRequestModel>? incomingRequests;
  
  UserSettingsModel? userSettings;

  bool isLoadingPersonal = true;
  bool isLoadingIncoming = true;

  bool get isManagerOrHr {
    if (userSettings == null) return false;
    return userSettings?.topManagement == true || 
           userSettings?.isHr == true || 
           (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty);
  }

  bool isIncomingView = false;

  void toggleIncomingView(bool value) {
    isIncomingView = value;
    notifyListeners();
  }

  void updateLoadingPersonal(bool value) {
    isLoadingPersonal = value;
    notifyListeners();
  }

  void updateLoadingIncoming(bool value) {
    isLoadingIncoming = value;
    notifyListeners();
  }

  Future<void> initializeScreen(BuildContext context) async {
    _loadUserSettings();
    
    // Load personal requests
    await getPersonalRequests(context: context);

    // Load incoming requests if manager/HR
    if (isManagerOrHr) {
      await getIncomingRequests(context: context);
    }
  }

  void _loadUserSettings() {
    var jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      var gCache = json.decode(jsonString) as Map<String, dynamic>;
      userSettings = UserSettingsModel.fromJson(gCache);
      UserSettingConst.userSettings = userSettings;
    }
  }

  Future<void> getPersonalRequests({required BuildContext context, int page = 1}) async {
    if (page == 1) {
      updateLoadingPersonal(true);
    }
    try {
      final result = await SalaryAdvanceRepo.getPersonalList(context: context, page: page);
      if (result.success && result.data != null) {
        var listData = result.data?['data'] as List<dynamic>?;
        if (page == 1) {
          personalRequests = listData?.map((item) => SalaryAdvanceRequestModel.fromJson(item)).toList();
        } else {
          personalRequests?.addAll(listData?.map((item) => SalaryAdvanceRequestModel.fromJson(item)).toList() ?? []);
        }
      }
    } catch (e) {
      debugPrint("Error fetching personal salary advance requests: $e");
    } finally {
      updateLoadingPersonal(false);
    }
  }

  Future<void> getIncomingRequests({required BuildContext context, int page = 1}) async {
    if (page == 1) {
      updateLoadingIncoming(true);
    }
    try {
      final result = await SalaryAdvanceRepo.getIncomingList(context: context, page: page);
      if (result.success && result.data != null) {
        var listData = result.data?['data'] as List<dynamic>?;
        if (page == 1) {
          incomingRequests = listData?.map((item) => SalaryAdvanceRequestModel.fromJson(item)).toList();
        } else {
          incomingRequests?.addAll(listData?.map((item) => SalaryAdvanceRequestModel.fromJson(item)).toList() ?? []);
        }
      }
    } catch (e) {
      debugPrint("Error fetching incoming salary advance requests: $e");
    } finally {
      updateLoadingIncoming(false);
    }
  }

  void removeRequestLocally(int id) {
    if (personalRequests != null) {
      personalRequests!.removeWhere((element) => element.id == id);
    }
    if (incomingRequests != null) {
      incomingRequests!.removeWhere((element) => element.id == id);
    }
    notifyListeners();
  }
}
