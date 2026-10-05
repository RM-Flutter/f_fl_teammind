import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/models/settings/general_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../shared/models/expense_claim_model.dart';
import '../shared/repos/expense_claim_repo.dart';
import '../../../core/services/requests_services.dart';

class ExpenseClaimListController extends ChangeNotifier {
  List<ExpenseClaimModel>? personalRequests;
  List<ExpenseClaimModel>? incomingRequests;

  UserSettingsModel? userSettings;

  bool isLoadingPersonal = true;
  bool isLoadingIncoming = true;

  int personalCurrentPage = 1;
  bool personalHasMore = true;
  bool personalIsLoadingMore = false;

  int incomingCurrentPage = 1;
  bool incomingHasMore = true;
  bool incomingIsLoadingMore = false;

  ExpenseClaimListController() {
    _loadUserSettings();
  }

  bool get isManagerOrHr {
    if (userSettings == null) return false;

    final isHr = userSettings?.isHr == true || userSettings?.topManagement == true;
    if (isHr) return true;

    final hasManagerRole =
        userSettings?.role?.map((e) => e.toLowerCase()).contains('manager') == true;
    final isManagerOrTL =
        (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty) ||
            hasManagerRole ||
            (userSettings?.isTeamleaderIn != null && userSettings!.isTeamleaderIn!.isNotEmpty);

    return isManagerOrTL;
  }

  bool get canModifyIncoming {
    if (userSettings == null) return false;

    final isHr = userSettings?.isHr == true || userSettings?.topManagement == true;
    if (isHr) return true;

    final hasManagerRole =
        userSettings?.role?.map((e) => e.toLowerCase()).contains('manager') == true;
    final isManager =
        (userSettings?.isManagerIn != null && userSettings!.isManagerIn!.isNotEmpty) ||
            hasManagerRole;
    if (isManager) {
      return UserSettingConst.generalSettingsModel?.managerAbleToApproveExpenseClaims == true;
    }

    return false;
  }

  bool get canEdit {
    if (userSettings == null) return false;
    return userSettings?.isHr == true || userSettings?.topManagement == true;
  }

  bool get isHrOrTopManagement =>
      userSettings?.isHr == true || userSettings?.topManagement == true;

  bool isIncomingView = false;
  String incomingScope = 'team';

  void setIncomingScope(String scope, BuildContext context) {
    incomingScope = scope;
    incomingCurrentPage = 1;
    incomingRequests = null;
    incomingHasMore = true;
    notifyListeners();
    getIncomingRequests(context: context);
  }

  void toggleIncomingView(bool value, BuildContext context) {
    isIncomingView = value;
    if (value) {
      incomingScope = 'team';
      incomingRequests = null;
      incomingHasMore = true;
      incomingCurrentPage = 1;
    }
    notifyListeners();
    if (value) {
      getIncomingRequests(context: context);
    } else if (personalRequests == null) {
      getPersonalRequests(context: context);
    }
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
    await getPersonalRequests(context: context);
    if (isManagerOrHr) {
      await getIncomingRequests(context: context);
    }
  }

  void _loadUserSettings() {
    var jsonString = CacheHelper.getString('US1');
    if (jsonString != null && jsonString.isNotEmpty && jsonString != '') {
      var gCache = json.decode(jsonString) as Map<String, dynamic>;
      userSettings = UserSettingsModel.fromJson(gCache);
      UserSettingConst.userSettings = userSettings;
    }
    var jsonString3 = CacheHelper.getString('US3');
    if (jsonString3 != null && jsonString3.isNotEmpty && jsonString3 != '') {
      var gCache3 = json.decode(jsonString3) as Map<String, dynamic>;
      UserSettingConst.generalSettingsModel = GeneralSettingsModel.fromJson(gCache3);
    }
  }

  Map<String, String?> personalFilters = {};
  Map<String, String?> incomingFilters = {};

  Map<String, String?> get currentFiltersMap =>
      isIncomingView ? incomingFilters : personalFilters;

  String? get filterEmpId => currentFiltersMap['empId'];
  String? get filterEmpName => currentFiltersMap['empName'];
  String? get filterDepId => currentFiltersMap['depId'];
  String? get filterDepName => currentFiltersMap['depName'];
  String? get filterStatus => currentFiltersMap['status'];
  String? get filterFrom => currentFiltersMap['from'];
  String? get filterTo => currentFiltersMap['to'];

  void applyFilters(Map<String, String?> filters, BuildContext context) {
    if (isIncomingView) {
      incomingFilters = Map.from(filters);
    } else {
      personalFilters = Map.from(filters);
    }
    if (isIncomingView) {
      getIncomingRequests(context: context);
    } else {
      getPersonalRequests(context: context);
    }
  }

  void clearFilterEmp(BuildContext context) {
    final filters = Map<String, String?>.from(currentFiltersMap);
    filters['empId'] = null;
    filters['empName'] = null;
    applyFilters(filters, context);
  }

  void clearFilterDep(BuildContext context) {
    final filters = Map<String, String?>.from(currentFiltersMap);
    filters['depId'] = null;
    filters['depName'] = null;
    applyFilters(filters, context);
  }

  void clearFilterDate(BuildContext context) {
    final filters = Map<String, String?>.from(currentFiltersMap);
    filters['from'] = null;
    filters['to'] = null;
    applyFilters(filters, context);
  }

  void clearFilterStatus(BuildContext context) {
    final filters = Map<String, String?>.from(currentFiltersMap);
    filters['status'] = null;
    applyFilters(filters, context);
  }

  void resetAllFilters() {
    personalFilters.clear();
    incomingFilters.clear();
  }

  Future<void> getPersonalRequests({
    required BuildContext context,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!personalHasMore || personalIsLoadingMore) return;
      personalIsLoadingMore = true;
      personalCurrentPage++;
      notifyListeners();
    } else {
      personalCurrentPage = 1;
      personalHasMore = true;
      updateLoadingPersonal(true);
    }

    try {
      final result = await ExpenseClaimRepo.getPersonalList(
        context: context,
        page: personalCurrentPage,
        departmentIds:
            (filterDepId != null && filterDepId!.isNotEmpty) ? [filterDepId!] : null,
        status: filterStatus,
        dateFrom: filterFrom,
        dateTo: filterTo,
      );

      if (result.success && result.data != null) {
        var listData = result.data?['approvables'] as List<dynamic>?;
        if (listData == null || listData.isEmpty) {
          personalHasMore = false;
        }
        if (personalCurrentPage == 1) {
          personalRequests = listData
              ?.map((item) => ExpenseClaimModel.fromApprovableJson(item))
              .toList();
        } else {
          personalRequests?.addAll(
            listData
                    ?.map((item) => ExpenseClaimModel.fromApprovableJson(item))
                    .toList() ??
                [],
          );
        }
      } else {
        personalHasMore = false;
        if (!loadMore) personalRequests = [];
      }
    } catch (e) {
      debugPrint('Error fetching personal expense claims: $e');
    } finally {
      personalIsLoadingMore = false;
      updateLoadingPersonal(false);
    }
  }

  Future<void> getIncomingRequests({
    required BuildContext context,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!incomingHasMore || incomingIsLoadingMore) return;
      incomingIsLoadingMore = true;
      incomingCurrentPage++;
      notifyListeners();
    } else {
      incomingCurrentPage = 1;
      incomingHasMore = true;
      updateLoadingIncoming(true);
    }

    try {
      final result = await RequestsServices.getManagerApprovables(
        context: context,
        type: 'employee_expense_claims',
        scope: incomingScope,
        page: incomingCurrentPage,
        employeesIds:
            (filterEmpId != null && filterEmpId!.isNotEmpty) ? [filterEmpId!] : null,
        departmentIds:
            (filterDepId != null && filterDepId!.isNotEmpty) ? [filterDepId!] : null,
        status: filterStatus,
        dateFrom: filterFrom,
        dateTo: filterTo,
      );

      if (result.success && result.data != null) {
        var listData = result.data?['approvables'] as List<dynamic>?;
        if (listData == null || listData.isEmpty) {
          incomingHasMore = false;
        }
        if (incomingCurrentPage == 1) {
          incomingRequests = listData
              ?.map((item) => ExpenseClaimModel.fromApprovableJson(item))
              .toList();
        } else {
          incomingRequests?.addAll(
            listData
                    ?.map((item) => ExpenseClaimModel.fromApprovableJson(item))
                    .toList() ??
                [],
          );
        }
      } else {
        incomingHasMore = false;
        if (!loadMore) incomingRequests = [];
      }
    } catch (e) {
      debugPrint('Error fetching incoming expense claims: $e');
    } finally {
      incomingIsLoadingMore = false;
      updateLoadingIncoming(false);
    }
  }

  void removeRequestLocally(int id) {
    personalRequests?.removeWhere((e) => e.id == id);
    incomingRequests?.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
