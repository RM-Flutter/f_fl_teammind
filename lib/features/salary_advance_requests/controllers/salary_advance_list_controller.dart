import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
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
    
    // 1. HR / Top Management: Always allowed
    final isHr = userSettings?.isHr == true || userSettings?.topManagement == true;
    if (isHr) return true;

    // 2. Manager / Team Leader: Allowed only if manager_able_to_approve_salary_advances is true
    final hasManagerRole = userSettings?.role?.map((e) => e.toLowerCase()).contains('manager') == true;
    final isManagerOrTL = (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty) || hasManagerRole || (userSettings?.isTeamleaderIn != null && userSettings!.isTeamleaderIn!.isNotEmpty);
    if (isManagerOrTL) {
      return UserSettingConst.generalSettingsModel?.managerAbleToApproveSalaryAdvances == true;
    }

    return false;
  }

  bool get canModifyIncoming {
    if (userSettings == null) return false;

    // 1. HR / Top Management: Always allowed
    final isHr = userSettings?.isHr == true || userSettings?.topManagement == true;
    if (isHr) return true;

    // 2. Manager: Allowed only if manager_able_to_approve_salary_advances is true
    final hasManagerRole = userSettings?.role?.map((e) => e.toLowerCase()).contains('manager') == true;
    final isManager = (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty) || hasManagerRole;
    if (isManager) {
      return UserSettingConst.generalSettingsModel?.managerAbleToApproveSalaryAdvances == true;
    }

    // 3. Team Leader / Employee / Anyone else: NEVER allowed
    return false;
  }

  bool get canEdit {
    if (userSettings == null) return false;
    // Only HR and Top Management can edit. Managers cannot edit.
    return userSettings?.isHr == true || userSettings?.topManagement == true;
  }

  bool isIncomingView = false;

  void toggleIncomingView(bool value, BuildContext context) {
    isIncomingView = value;
    
    filterEmpId = null;
    filterEmpName = null;
    filterDepId = null;
    filterDepName = null;
    filterStatus = null;
    filterFrom = null;
    filterTo = null;
    
    getPersonalRequests(context: context);
    if (isManagerOrHr) {
      getIncomingRequests(context: context);
    }
    
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
    var jsonString3 = CacheHelper.getString("US3");
    if (jsonString3 != null && jsonString3.isNotEmpty && jsonString3 != "") {
      var gCache3 = json.decode(jsonString3) as Map<String, dynamic>;
      UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache3);
    }
  }

  String? filterEmpId;
  String? filterEmpName;
  String? filterDepId;
  String? filterDepName;
  String? filterStatus;
  String? filterFrom;
  String? filterTo;

  void applyFilters(Map<String, String?> filters, BuildContext context) {
    filterEmpId = filters['empId'];
    filterEmpName = filters['empName'];
    filterDepId = filters['depId'];
    filterDepName = filters['depName'];
    filterStatus = filters['status'];
    filterFrom = filters['from'];
    filterTo = filters['to'];
    
    getPersonalRequests(context: context);
    if (isManagerOrHr) {
      getIncomingRequests(context: context);
    }
  }

  void clearFilterEmp(BuildContext context) {
    filterEmpId = null;
    filterEmpName = null;
    applyFilters(currentFiltersMap, context);
  }

  void clearFilterDep(BuildContext context) {
    filterDepId = null;
    filterDepName = null;
    applyFilters(currentFiltersMap, context);
  }

  void clearFilterDate(BuildContext context) {
    filterFrom = null;
    filterTo = null;
    applyFilters(currentFiltersMap, context);
  }

  void clearFilterStatus(BuildContext context) {
    filterStatus = null;
    applyFilters(currentFiltersMap, context);
  }

  Map<String, String?> get currentFiltersMap => {
    'empId': filterEmpId,
    'empName': filterEmpName,
    'depId': filterDepId,
    'depName': filterDepName,
    'status': filterStatus,
    'from': filterFrom,
    'to': filterTo,
  };

  Future<void> getPersonalRequests({required BuildContext context, int page = 1}) async {
    if (page == 1) {
      updateLoadingPersonal(true);
    }
    try {
      final result = await SalaryAdvanceRepo.getPersonalList(
        context: context, 
        page: page,
        from: filterFrom ?? '',
        to: filterTo ?? '',
        departmentId: filterDepId ?? '',
        status: filterStatus ?? '',
      );
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
      final result = await SalaryAdvanceRepo.getIncomingList(
        context: context, 
        page: page,
        employeeId: filterEmpId ?? '',
        from: filterFrom ?? '',
        to: filterTo ?? '',
        departmentId: filterDepId ?? '',
        status: filterStatus ?? '',
      );
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
