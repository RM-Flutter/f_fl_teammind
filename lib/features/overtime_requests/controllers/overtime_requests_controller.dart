import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../employee_profiles/shared/repos/employee_repo.dart';
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

  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  Map<String, String?> personalFilters = {};
  Map<String, String?> incomingFilters = {};

  Map<String, String?> get currentFiltersMap => isForDepartment ? incomingFilters : personalFilters;

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

  Future<void> fetchRequests(BuildContext context, {bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore || isLoadingMore) return;
      isLoadingMore = true;
      currentPage++;
      notifyListeners();
    } else {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      notifyListeners();
    }

    try {
      // Fetch employees to map names if they are missing
      Map<int, String> employeeNames = {};
      try {
        final empResponse = await EmployeeService.getEmployees(context: context);
        if (empResponse.success && empResponse.data != null && empResponse.data!['employees'] != null) {
          final List<dynamic> emps = empResponse.data!['employees'];
          for (var e in emps) {
            if (e['id'] != null && e['name'] != null) {
              employeeNames[int.tryParse(e['id'].toString()) ?? 0] = e['name'];
            }
          }
        }
      } catch (e) {
        debugPrint("Error fetching employees for mapping: $e");
      }

      final response = await OvertimeRequestsService.getOvertimeRequests(
        context: context,
        employeeProfileId: filterEmpId,
        departmentId: filterDepId,
        from: filterFrom,
        to: filterTo,
        page: currentPage,
      );
      
      if (response.success && response.data != null && response.data!['requests'] != null) {
        final List<dynamic> requestsData = response.data!['requests'];
        List<OvertimeRequestModel> allRequests = requestsData.map((e) {
          final model = OvertimeRequestModel.fromJson(e);
          // If name is missing, try to map it from our employee list
          if ((model.employeeName == null || model.employeeName!.isEmpty) && model.employeeProfileId != null) {
            model.employeeName = employeeNames[model.employeeProfileId];
          }
          return model;
        }).toList();

        // Apply local filtering as a fallback since the backend currently ignores some filters
        if (filterEmpId != null && filterEmpId!.isNotEmpty) {
          final int? empId = int.tryParse(filterEmpId!);
          if (empId != null) {
            allRequests = allRequests.where((e) => e.employeeProfileId == empId).toList();
          }
        }

        if (filterDepName != null && filterDepName!.isNotEmpty) {
          allRequests = allRequests.where((e) => e.employeeProfile?.department == filterDepName).toList();
        }

        final String? jsonString = CacheHelper.getString("US1");
        int? currentUserId;
        if (jsonString != null && jsonString.isNotEmpty) {
          final Map<String, dynamic> gCache = json.decode(jsonString);
          if (gCache['employee_profile_id'] != null) {
             currentUserId = int.tryParse(gCache['employee_profile_id'].toString());
          }
          if (currentUserId == null && gCache['id'] != null) {
             currentUserId = int.tryParse(gCache['id'].toString());
          }
        }
        
        if (currentUserId != null) {
           final newMyRequests = allRequests.where((element) => element.employeeProfileId == currentUserId).toList();
           final newTeamRequests = allRequests.where((element) => element.employeeProfileId != currentUserId).toList();
           
           if (loadMore) {
             teamRequests.addAll(newTeamRequests);
             myRequests.addAll(newMyRequests);
           } else {
             teamRequests = newTeamRequests;
             myRequests = newMyRequests;
           }
        } else {
           if (loadMore) {
             myRequests.addAll(allRequests);
           } else {
             myRequests = allRequests;
             teamRequests = [];
           }
        }
        
        if (allRequests.isEmpty) {
          hasMore = false;
        }

      } else {
        hasMore = false;
        if (!loadMore) {
          teamRequests = [];
          myRequests = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching overtime requests: $e");
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  void toggleDepartmentView(bool value, BuildContext context) {
    isForDepartment = value;
    notifyListeners();
    if (value && teamRequests.isEmpty) {
      fetchRequests(context);
    } else if (!value && myRequests.isEmpty) {
      fetchRequests(context);
    }
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
