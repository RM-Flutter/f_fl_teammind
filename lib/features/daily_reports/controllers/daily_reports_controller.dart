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

  String? filterEmpId;
  String? filterEmpName;
  String? filterDepId;
  String? filterDepName;
  String? filterFrom;
  String? filterTo;

  void applyFilters(Map<String, String?> filters, BuildContext context) {
    filterEmpId = filters['empId'];
    filterEmpName = filters['empName'];
    filterDepId = filters['depId'];
    filterDepName = filters['depName'];
    filterFrom = filters['from'];
    filterTo = filters['to'];
    
    fetchReports(context);
    if (isManagerOrHr) {
      fetchReports(context, isIncoming: true);
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

  Map<String, String?> get currentFiltersMap => {
    'empId': filterEmpId,
    'empName': filterEmpName,
    'depId': filterDepId,
    'depName': filterDepName,
    'from': filterFrom,
    'to': filterTo,
  };

  Future<void> fetchReports(BuildContext context, {int page = 1, bool isIncoming = false}) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await DailyReportsService.getReports(
        context: context, 
        page: page, 
        isIncoming: isIncoming,
        employeeId: filterEmpId,
        departmentId: filterDepId,
        from: filterFrom,
        to: filterTo,
      );
      if (response.success && response.data != null && response.data!['data'] != null) {
        final List<dynamic> reportsData = response.data!['data'];
        final list = reportsData.map((e) => DailyReportModel.fromJson(e)).toList();
        if (isIncoming) {
          incomingReports = list;
        } else {
          personalReports = list;
        }
      } else {
        if (isIncoming) {
          incomingReports = [];
        } else {
          personalReports = [];
        }
      }
    } catch (e) {
      debugPrint("Error fetching daily reports: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleDepartmentView(bool value, BuildContext context) {
    isForDepartment = value;
    
    filterEmpId = null;
    filterEmpName = null;
    filterDepId = null;
    filterDepName = null;
    filterFrom = null;
    filterTo = null;
    
    fetchReports(context);
    if (isManagerOrHr) {
      fetchReports(context, isIncoming: true);
    }
    
    notifyListeners();
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
