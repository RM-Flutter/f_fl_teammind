import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
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
      final int? currentUserId = _getCurrentUserId();

      // For personal view: always send current user's ID to backend
      // For incoming/team view: send filterEmpId if user filtered by employee, else null
      String? apiEmployeeProfileId;
      if (!isForDepartment) {
        // Personal tab: send the current user's employee_profile_id
        if (currentUserId != null) {
          apiEmployeeProfileId = currentUserId.toString();
        }
      } else {
        // Team/Incoming tab: send the filtered employee ID if selected, otherwise null
        apiEmployeeProfileId = (filterEmpId != null && filterEmpId!.isNotEmpty) ? filterEmpId : null;
      }

      final pageToLoad = isForDepartment ? incomingCurrentPage : personalCurrentPage;
      final response = await OvertimeRequestsService.getOvertimeRequests(
        context: context,
        employeeProfileId: apiEmployeeProfileId,
        departmentId: filterDepId,
        from: filterFrom,
        to: filterTo,
        page: pageToLoad,
      );

      if (response.success && response.data != null && response.data!['requests'] != null) {
        final List<dynamic> requestsData = response.data!['requests'];
        final List<OvertimeRequestModel> newRequests = requestsData.map((e) {
          return OvertimeRequestModel.fromJson(e);
        }).toList();

        // Use the total from API response for accurate hasMore detection
        final int apiTotal = (response.data!['total'] as num?)?.toInt() ?? 0;

        if (isForDepartment) {
          // For incoming: no client-side filtering needed, rely on backend
          if (loadMore) {
            teamRequests.addAll(newRequests);
          } else {
            incomingTotal = apiTotal;
            teamRequests = newRequests.toList();
          }
          // No more pages if we've loaded all records or got empty results
          if (newRequests.isEmpty || teamRequests.length >= incomingTotal) {
            incomingHasMore = false;
          }
        } else {
          // For personal: the API already filters by our employee_profile_id
          if (loadMore) {
            myRequests.addAll(newRequests);
          } else {
            personalTotal = apiTotal;
            myRequests = newRequests.toList();
          }
          // No more pages if we've loaded all records or got empty results
          if (newRequests.isEmpty || myRequests.length >= personalTotal) {
            personalHasMore = false;
          }
        }

      } else {
        if (isForDepartment) {
          incomingHasMore = false;
          if (!loadMore) teamRequests = [];
        } else {
          personalHasMore = false;
          if (!loadMore) myRequests = [];
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
