import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/daily_report_model.dart';
import '../services/daily_reports_service.dart';

class DailyReportsProvider extends ChangeNotifier {
  List<DailyReportModel> personalReports = [];
  List<DailyReportModel> incomingReports = [];
  bool isLoading = false;
  bool isActionLoading = false;
  bool isManagerOrHr = false;
  bool isForDepartment = false;

  int personalCurrentPage = 1;
  bool personalHasMore = true;
  bool personalIsLoadingMore = false;

  int incomingCurrentPage = 1;
  bool incomingHasMore = true;
  bool incomingIsLoadingMore = false;

  DailyReportsProvider() {
    _checkRole();
  }

  void _checkRole() {
    final String? jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final gCache = json.decode(jsonString) as Map<String, dynamic>;
        if (gCache['is_manager_in'] != null && gCache['is_manager_in'] is List && gCache['is_manager_in'].isNotEmpty) {
          isManagerOrHr = true;
        }
        if (gCache['is_teamleader_in'] != null && gCache['is_teamleader_in'] is List && gCache['is_teamleader_in'].isNotEmpty) {
          isManagerOrHr = true;
        }
        if (gCache['is_hr'] == true || gCache['top_management'] == true) {
          isManagerOrHr = true;
        }
        if (gCache['role'] != null && gCache['role'] is List) {
          final roles = gCache['role'] as List;
          if (roles.contains('hr') || roles.contains('manager') || roles.contains('hr_admin')) {
            isManagerOrHr = true;
          }
        }
      } catch (e) {
        debugPrint("Error parsing user1 cache for role: $e");
      }
    }
  }

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
    fetchReports(context, isIncoming: isForDepartment);
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

  Future<void> fetchReports(BuildContext context, {bool isIncoming = false, bool loadMore = false}) async {
    if (loadMore) {
      if (isIncoming) {
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
      if (isIncoming) {
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
      final pageToLoad = isIncoming ? incomingCurrentPage : personalCurrentPage;
      final response = await DailyReportsService.getReports(
        context: context, 
        page: pageToLoad, 
        isIncoming: isIncoming,
        employeeId: filterEmpId,
        departmentId: filterDepId,
        from: filterFrom,
        to: filterTo,
      );
      if (response.success && response.data != null && response.data!['data'] != null) {
        final List<dynamic> reportsData = response.data!['data'];
        final list = reportsData.map((e) => DailyReportModel.fromJson(e)).toList();
        
        if (list.isEmpty) {
          if (isIncoming) {
            incomingHasMore = false;
          } else {
            personalHasMore = false;
          }
        }

        if (loadMore) {
          if (isIncoming) {
            incomingReports.addAll(list);
          } else {
            personalReports.addAll(list);
          }
        } else {
          if (isIncoming) {
            incomingReports = list;
          } else {
            personalReports = list;
          }
        }
      } else {
        if (isIncoming) {
          incomingHasMore = false;
          if (!loadMore) incomingReports = [];
        } else {
          personalHasMore = false;
          if (!loadMore) personalReports = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching daily reports: $e");
    }

    isLoading = false;
    if (isIncoming) {
      incomingIsLoadingMore = false;
    } else {
      personalIsLoadingMore = false;
    }
    notifyListeners();
  }

  void toggleDepartmentView(bool value, BuildContext context) {
    isForDepartment = value;
    notifyListeners();
    // Only fetch if the list is empty since filters are preserved
    if (value && incomingReports.isEmpty) {
      fetchReports(context, isIncoming: true);
    } else if (!value && personalReports.isEmpty) {
      fetchReports(context, isIncoming: false);
    }
  }

  Future<bool> addReport(
    BuildContext context, 
    String done, 
    String inProgress, 
    String problems, 
    List<FilePickerResult> files
  ) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await DailyReportsService.createReport(
        context: context,
        done: done,
        inProgress: inProgress,
        problems: problems,
        files: files,
      );
      if (response.success) {
        success = true;
        await fetchReports(context);
      }
    } catch (e) {
      debugPrint("Error adding daily report: $e");
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateReport(
    BuildContext context, 
    String reportId, 
    String done, 
    String inProgress, 
    String problems, 
    List<FilePickerResult> files
  ) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await DailyReportsService.updateReport(
        context: context,
        reportId: reportId,
        done: done,
        inProgress: inProgress,
        problems: problems,
        files: files,
      );
      if (response.success) {
        success = true;
        await fetchReports(context);
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context, 
            message: response.message ?? 'error_occurred'.tr(),
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating daily report: $e");
      if (context.mounted) {
        AlertsService.error(
          context: context, 
          message: 'error_occurred'.tr(),
          title: 'error'.tr(),
        );
      }
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteReport(BuildContext context, String reportId) async {
    isActionLoading = true;
    notifyListeners();
    bool success = false;
    try {
      final response = await DailyReportsService.deleteReport(
        context: context,
        reportId: reportId,
      );
      if (response.success) {
        success = true;
        await fetchReports(context);
      } else {
        if (context.mounted) {
          AlertsService.error(
            context: context, 
            message: response.message ?? 'error_occurred'.tr(),
            title: 'error'.tr(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error deleting daily report: $e");
      if (context.mounted) {
        AlertsService.error(
          context: context, 
          message: 'error_occurred'.tr(),
          title: 'error'.tr(),
        );
      }
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }
}
