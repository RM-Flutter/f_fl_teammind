import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import '../../../core/services/requests_services.dart';
import '../models/overtime_request_model.dart';
import '../services/overtime_requests_service.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:easy_localization/easy_localization.dart';

class OvertimeRequestsProvider extends ChangeNotifier {
  List<OvertimeRequestModel> myRequests = [];
  List<OvertimeRequestModel> teamRequests = [];

  bool isLoading = false;
  bool isActionLoading = false;
  bool isForDepartment = false;

  int personalCurrentPage = 1;
  bool personalHasMore = true;
  bool personalIsLoadingMore = false;
  int personalTotal = 0;

  int incomingCurrentPage = 1;
  bool incomingHasMore = true;
  bool incomingIsLoadingMore = false;
  int incomingTotal = 0;

  Map<String, String?> personalFilters = {};
  Map<String, String?> incomingFilters = {};

  Map<String, String?> get currentFiltersMap =>
      isForDepartment ? incomingFilters : personalFilters;

  String? get filterEmpId => currentFiltersMap['empId'];
  String? get filterEmpName => currentFiltersMap['empName'];
  String? get filterDepId => currentFiltersMap['depId'];
  String? get filterDepName => currentFiltersMap['depName'];
  String? get filterFrom => currentFiltersMap['from'];
  String? get filterTo => currentFiltersMap['to'];

  void applyFilters(Map<String, String?> filters, BuildContext context) {
    if (isForDepartment) {
      incomingFilters = Map.from(filters);
    } else {
      personalFilters = Map.from(filters);
    }
    fetchRequests(context);
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

  void resetAllFilters() {
    personalFilters.clear();
    incomingFilters.clear();
  }

  /// Gets the current user's employee_profile_id from cache
  int? _getCurrentUserId() {
    // First try from UserSettingConst (already loaded)
    if (UserSettingConst.userSettings?.empId != null) {
      return UserSettingConst.userSettings!.empId;
    }
    // Fallback: parse from cache string
    final String? jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> gCache = json.decode(jsonString);
        // Load into UserSettingConst for next time
        UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
        return UserSettingConst.userSettings?.empId;
      } catch (e) {
        debugPrint("Error parsing user cache: $e");
      }
    }
    return null;
  }

  Future<void> fetchRequests(BuildContext context, {bool loadMore = false}) async {
    if (loadMore) {
      if (isForDepartment) {
        if (!incomingHasMore || incomingIsLoadingMore) return;
        incomingIsLoadingMore = true;
        incomingCurrentPage++;
      } else {
        if (!personalHasMore || personalIsLoadingMore) return;
        personalIsLoadingMore = true;
        personalCurrentPage++;
      }
      notifyListeners();
    } else {
      if (isForDepartment) {
        incomingCurrentPage = 1;
        incomingHasMore = true;
      } else {
        personalCurrentPage = 1;
        personalHasMore = true;
      }
      isLoading = true;
      notifyListeners();
    }

    try {
      // ─── Personal (mine) tab: NEW unified Approvals endpoint ─────────────
      if (!isForDepartment) {
        final List<String>? empIdsList =
            (filterEmpId != null && filterEmpId!.isNotEmpty) ? [filterEmpId!] : null;
        final List<String>? depIdsList =
            (filterDepId != null && filterDepId!.isNotEmpty) ? [filterDepId!] : null;

        final response = await OvertimeRequestsService.getMyApprovablesOvertime(
          context: context,
          employeesIds: empIdsList,
          departmentIds: depIdsList,
          dateFrom: filterFrom,
          dateTo: filterTo,
          page: personalCurrentPage,
        );

        if (response.success && response.data != null && response.data!['approvables'] != null) {
          final List<dynamic> approvablesData = response.data!['approvables'];
          final List<OvertimeRequestModel> newRequests =
              approvablesData.map((e) => OvertimeRequestModel.fromApprovableJson(e)).toList();

          final int apiTotal = (response.data!['total'] as num?)?.toInt() ?? 0;

          if (loadMore) {
            myRequests.addAll(newRequests);
          } else {
            personalTotal = apiTotal;
            myRequests = newRequests.toList();
          }
          if (newRequests.isEmpty || myRequests.length >= personalTotal) {
            personalHasMore = false;
          }
        } else {
          personalHasMore = false;
          if (!loadMore) myRequests = [];
        }
      } else {
        // ─── Team/Incoming tab: NEW unified Approvals API ─────────────────────
        final List<String>? empIdsList =
            (filterEmpId != null && filterEmpId!.isNotEmpty) ? [filterEmpId!] : null;
        final List<String>? depIdsList =
            (filterDepId != null && filterDepId!.isNotEmpty) ? [filterDepId!] : null;

        final response = await RequestsServices.getManagerApprovables(
          context: context,
          type: 'overtime',
          scope: 'team', // default scope for department view
          employeesIds: empIdsList,
          departmentIds: depIdsList,
          dateFrom: filterFrom,
          dateTo: filterTo,
          page: incomingCurrentPage,
        );

        if (response.success && response.data != null && response.data!['approvables'] != null) {
          final List<dynamic> requestsData = response.data!['approvables'];
          final List<OvertimeRequestModel> newRequests =
              requestsData.map((e) => OvertimeRequestModel.fromApprovableJson(e)).toList();

          final int apiTotal = (response.data!['total'] as num?)?.toInt() ?? 0;

          if (loadMore) {
            teamRequests.addAll(newRequests);
          } else {
            incomingTotal = apiTotal;
            teamRequests = newRequests.toList();
          }
          if (newRequests.isEmpty || teamRequests.length >= incomingTotal) {
            incomingHasMore = false;
          }
        } else {
          incomingHasMore = false;
          if (!loadMore) teamRequests = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching overtime requests: $e");
    }

    isLoading = false;
    if (isForDepartment) {
      incomingIsLoadingMore = false;
    } else {
      personalIsLoadingMore = false;
    }
    notifyListeners();
  }

  void toggleDepartmentView(bool value, BuildContext context) {
    isForDepartment = value;
    
    // Reset pagination and clear lists on switch
    if (value) {
      incomingCurrentPage = 1;
      teamRequests.clear();
      incomingHasMore = true;
    } else {
      personalCurrentPage = 1;
      myRequests.clear();
      personalHasMore = true;
    }
    
    notifyListeners();
    // Always fetch requests on every switch
    fetchRequests(context);
  }

  Future<bool> addManagerRequest(BuildContext context, String date, String overtime, String employeeProfileId) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await OvertimeRequestsService.addManagerOvertimeRequest(
        context: context,
        date: date,
        overtime: overtime,
        employeeProfileId: employeeProfileId,
      );
      if (response.success) {
        success = true;
        await fetchRequests(context);
      } else if (response.message != null && response.message!.isNotEmpty) {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: response.message!,
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error adding manager overtime request: $e");
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> addRequest(BuildContext context, String date, String overtime) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await OvertimeRequestsService.addOvertimeRequest(
        context: context,
        date: date,
        overtime: overtime,
      );
      if (response.success) {
        success = true;
        await fetchRequests(context);
      } else if (response.message != null && response.message!.isNotEmpty) {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: response.message!,
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error adding overtime request: $e");
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateRequestStatus(BuildContext context, String requestId, String status, String reply) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await OvertimeRequestsService.updateStatus(
        context: context,
        requestId: requestId,
        status: status,
        managerReply: reply,
      );
      if (response.success) {
        success = true;
        await fetchRequests(context);
      } else if (response.message != null && response.message!.isNotEmpty) {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: response.message!,
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateRequestDuration(BuildContext context, String requestId, String overtime) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await OvertimeRequestsService.updateOvertime(
        context: context,
        requestId: requestId,
        overtime: overtime,
      );
      if (response.success) {
        success = true;
        await fetchRequests(context);
      } else if (response.message != null && response.message!.isNotEmpty) {
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: response.message!,
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating duration: $e");
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }
}
