import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/user_consts.dart';
import '../../../core/services/alert_service/alerts_service.dart';
import '../../../core/services/requests_services.dart';
import '../models/shift_change_request_model.dart';
import '../services/shift_change_requests_service.dart';

class ShiftChangeController extends ChangeNotifier {
  List<ShiftChangeRequestModel> myRequests = [];
  List<ShiftChangeRequestModel> teamRequests = [];

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

  /// 'team' | 'other_departments' | 'all_company'
  String incomingScope = 'team';

  // Scheduler Calendar & Assignments state for Add Shift Change Request
  bool isCalendarLoading = false;
  bool isDepartmentShiftsLoading = false;
  bool isColleagueAssignmentsLoading = false;
  String? calendarActualFrom;
  String? calendarActualTo;
  String? calendarErrorMessage;
  String? colleagueAssignmentsError;
  List<SchedulerEmployeeModel> calendarEmployees = [];
  List<ShiftDefinitionModel> departmentShifts = [];
  List<ShiftAssignmentModel> colleagueAssignments = [];

  bool get isHrOrTopManagement {
    if (UserSettingConst.userSettings == null) return false;
    return UserSettingConst.userSettings!.isHr == true ||
        UserSettingConst.userSettings!.topManagement == true;
  }

  Map<String, String?> personalFilters = {};
  Map<String, String?> incomingFilters = {};

  Map<String, String?> get currentFiltersMap =>
      isForDepartment ? incomingFilters : personalFilters;

  String? get filterEmpId => currentFiltersMap['empId'];
  String? get filterEmpName => currentFiltersMap['empName'];
  String? get filterDepId => currentFiltersMap['depId'];
  String? get filterDepName => currentFiltersMap['depName'];
  String? get filterStatus => currentFiltersMap['status'];
  String? get filterFrom => currentFiltersMap['from'];
  String? get filterTo => currentFiltersMap['to'];

  void setIncomingScope(String scope, BuildContext context) {
    incomingScope = scope;
    incomingCurrentPage = 1;
    teamRequests.clear();
    incomingHasMore = true;
    notifyListeners();
    fetchRequests(context);
  }

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

  void clearFilterStatus(BuildContext context) {
    final filters = Map<String, String?>.from(currentFiltersMap);
    filters['status'] = null;
    applyFilters(filters, context);
  }

  void resetAllFilters() {
    personalFilters.clear();
    incomingFilters.clear();
  }

  void toggleDepartmentView(bool value, BuildContext context) {
    isForDepartment = value;
    if (value) {
      incomingCurrentPage = 1;
      incomingScope = 'team';
      teamRequests.clear();
      incomingHasMore = true;
    } else {
      personalCurrentPage = 1;
      myRequests.clear();
      personalHasMore = true;
    }
    notifyListeners();
    fetchRequests(context);
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
      final List<String>? empIdsList =
          (filterEmpId != null && filterEmpId!.isNotEmpty) ? [filterEmpId!] : null;
      final List<String>? depIdsList =
          (filterDepId != null && filterDepId!.isNotEmpty) ? [filterDepId!] : null;

      if (!isForDepartment) {
        final response = await ShiftChangeRequestsService.getMyShiftChangeRequests(
          context: context,
          employeesIds: empIdsList,
          departmentIds: depIdsList,
          status: filterStatus,
          dateFrom: filterFrom,
          dateTo: filterTo,
          page: personalCurrentPage,
        );

        if (response.success &&
            response.data != null &&
            response.data!['approvables'] is List) {
          final List<dynamic> approvablesData = response.data!['approvables'];
          final List<ShiftChangeRequestModel> newRequests = approvablesData
              .whereType<Map<String, dynamic>>()
              .map((e) => ShiftChangeRequestModel.fromApprovableJson(e))
              .toList();

          final int apiTotal = (response.data!['total'] as num?)?.toInt() ?? 0;

          if (loadMore) {
            myRequests.addAll(newRequests);
          } else {
            personalTotal = apiTotal;
            myRequests = newRequests;
          }
          if (newRequests.isEmpty || myRequests.length >= personalTotal) {
            personalHasMore = false;
          }
        } else {
          personalHasMore = false;
          if (!loadMore) myRequests = [];
        }
      } else {
        final response = await RequestsServices.getManagerApprovables(
          context: context,
          type: 'shift_change_requests',
          scope: incomingScope,
          employeesIds: empIdsList,
          departmentIds: depIdsList,
          status: filterStatus,
          dateFrom: filterFrom,
          dateTo: filterTo,
          page: incomingCurrentPage,
        );

        if (response.success &&
            response.data != null &&
            response.data!['approvables'] is List) {
          final List<dynamic> requestsData = response.data!['approvables'];
          final List<ShiftChangeRequestModel> newRequests = requestsData
              .whereType<Map<String, dynamic>>()
              .map((e) => ShiftChangeRequestModel.fromApprovableJson(e))
              .toList();

          final int apiTotal = (response.data!['total'] as num?)?.toInt() ?? 0;

          if (loadMore) {
            teamRequests.addAll(newRequests);
          } else {
            incomingTotal = apiTotal;
            teamRequests = newRequests;
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
      debugPrint("Error fetching shift change requests: $e");
    }

    isLoading = false;
    if (isForDepartment) {
      incomingIsLoadingMore = false;
    } else {
      personalIsLoadingMore = false;
    }
    notifyListeners();
  }

  /// Fetch scheduler calendar for date range (e.g. today to +14 days)
  Future<void> fetchSchedulerCalendar(
    BuildContext context, {
    required String from,
    required String to,
  }) async {
    isCalendarLoading = true;
    calendarErrorMessage = null;
    notifyListeners();

    try {
      final response = await ShiftChangeRequestsService.getSchedulerCalendar(
        context: context,
        from: from,
        to: to,
      );

      if (response.success &&
          response.data != null &&
          response.data!['status'] == true &&
          response.data!['employees'] is List) {
        calendarActualFrom = response.data!['from']?.toString();
        calendarActualTo = response.data!['to']?.toString();
        final List<dynamic> empList = response.data!['employees'];
        calendarEmployees = empList
            .whereType<Map<String, dynamic>>()
            .map((e) => SchedulerEmployeeModel.fromJson(e))
            .toList();
      } else {
        calendarEmployees = [];
        final errMsg = response.data?['message']?.toString() ?? response.message;
        if (errMsg != null && errMsg.trim().isNotEmpty) {
          calendarErrorMessage = errMsg.trim();
        }
      }
    } catch (e) {
      debugPrint("Error fetching scheduler calendar: $e");
      calendarEmployees = [];
    }

    isCalendarLoading = false;
    notifyListeners();
  }

  /// Fetch department shifts sorted by start time (GET /shifts)
  Future<void> fetchDepartmentShifts(BuildContext context) async {
    isDepartmentShiftsLoading = true;
    notifyListeners();

    try {
      final response = await ShiftChangeRequestsService.getDepartmentShifts(
        context: context,
      );

      if (response.success &&
          response.data != null &&
          response.data!['status'] == true &&
          response.data!['shifts'] is List) {
        final List<dynamic> shiftsList = response.data!['shifts'];
        departmentShifts = shiftsList
            .whereType<Map<String, dynamic>>()
            .map((e) => ShiftDefinitionModel.fromJson(e))
            .toList();
      } else {
        departmentShifts = [];
      }
    } catch (e) {
      debugPrint("Error fetching department shifts: $e");
      departmentShifts = [];
    }

    isDepartmentShiftsLoading = false;
    notifyListeners();
  }

  void clearColleagueAssignmentsLookup() {
    colleagueAssignments = [];
    colleagueAssignmentsError = null;
    notifyListeners();
  }

  /// Fetch colleague's assignments on a given date (GET /assignments)
  Future<void> fetchColleagueAssignments(
    BuildContext context, {
    required int employeeId,
    required String date,
    int? shiftId,
  }) async {
    isColleagueAssignmentsLoading = true;
    colleagueAssignmentsError = null;
    notifyListeners();

    try {
      final response = await ShiftChangeRequestsService.getEmployeeAssignments(
        context: context,
        employeeId: employeeId,
        date: date,
        shiftId: shiftId,
      );

      if (response.success &&
          response.data != null &&
          response.data!['status'] == true &&
          response.data!['assignments'] is List) {
        final List<dynamic> assignList = response.data!['assignments'];
        colleagueAssignments = assignList
            .whereType<Map<String, dynamic>>()
            .map((e) => ShiftAssignmentModel.fromJson(e))
            .toList();
      } else {
        colleagueAssignments = [];
        final errMsg = response.data?['message']?.toString() ?? response.message;
        if (errMsg != null && errMsg.trim().isNotEmpty) {
          colleagueAssignmentsError = errMsg.trim();
        }
      }
    } catch (e) {
      debugPrint("Error fetching colleague assignments: $e");
      colleagueAssignments = [];
    }

    isColleagueAssignmentsLoading = false;
    notifyListeners();
  }

  /// Submit a new shift change request
  Future<bool> submitShiftChangeRequest(
    BuildContext context, {
    required int receiverEmployeeId,
    required int requesterShiftAssignmentId,
    int? receiverShiftAssignmentId,
    required String reason,
  }) async {
    isActionLoading = true;
    notifyListeners();

    try {
      final response = await ShiftChangeRequestsService.createShiftChangeRequest(
        context: context,
        receiverEmployeeId: receiverEmployeeId,
        requesterShiftAssignmentId: requesterShiftAssignmentId,
        receiverShiftAssignmentId: receiverShiftAssignmentId,
        reason: reason,
      );

      isActionLoading = false;
      notifyListeners();

      final bool apiStatus = response.data?['status'] == true;
      if (response.success && apiStatus) {
        return true;
      } else {
        final String errMsg = response.data?['message']?.toString() ??
            response.message ??
            'something_went_wrong'.tr();
        if (context.mounted) {
          AlertsService.error(
            context: context,
            message: errMsg,
            title: 'error'.tr(),
          );
        }
        return false;
      }
    } catch (e) {
      isActionLoading = false;
      notifyListeners();
      if (context.mounted) {
        AlertsService.error(
          context: context,
          message: e.toString(),
          title: 'error'.tr(),
        );
      }
      return false;
    }
  }
}
