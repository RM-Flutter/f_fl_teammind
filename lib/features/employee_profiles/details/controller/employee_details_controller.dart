import 'dart:convert';

import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../../core/models/requests_model.dart';
import '../../../../core/services/requests_services.dart';
import '../../shared/models/employee_profile_model.dart';
import '../../shared/repos/employee_repo.dart';
import 'package:app_test/features/overtime_requests/models/overtime_request_model.dart';
import 'package:app_test/features/overtime_requests/services/overtime_requests_service.dart';
import 'package:app_test/features/daily_reports/models/daily_report_model.dart';
import 'package:app_test/features/daily_reports/services/daily_reports_service.dart';
import 'package:app_test/features/salary_advance_requests/shared/models/salary_advance_request_model.dart';
import 'package:app_test/features/salary_advance_requests/shared/repos/salary_advance_repo.dart';

class EmployeeDetailsViewModel extends ChangeNotifier {
  EmployeeProfileModel? employee;
  UserSettingsModel? currentUserSettings;
  bool isLoading = true;
  String? errorMessage;
  List? evaluations = [];
  List? salaryAdvances = [];
  List<DailyReportModel>? dailyReports;
  List<OvertimeRequestModel>? overtimeRequests;
  List<SalaryAdvanceRequestModel>? salaryAdvanceRequestsList;

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializeEmployeesListScreen(
      {required BuildContext context, required String employeeId,required bool getTeam, }) async {
    updateLoadingStatus(laodingValue: true);
    var jsonString;
    UserSettingsModel? userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    currentUserSettings = userSettingsModel;
    await _getEmployeeData(context: context, employeeId: employeeId);
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> fetchDataForIndex(int index, BuildContext context, {required bool getTeam, required String empId}) async {
    if (index == 2 && (salaryAdvances == null || salaryAdvances!.isEmpty)) {
      await getSaleryAdvance(context, getTeam: getTeam, empId: empId);
      notifyListeners();
    } else if (index == 5 && dailyReports == null) {
      await getDailyReports(context, empId: empId, getTeam: getTeam);
      notifyListeners();
    } else if (index == 6 && overtimeRequests == null) {
      await getOvertimeRequestsList(context, empId: empId, getTeam: getTeam);
    } else if (index == 7 && salaryAdvanceRequestsList == null) {
      await getSalaryAdvanceRequestsList(context, empId: empId, getTeam: getTeam);
    }
  }

  Future<void> getSaleryAdvance(BuildContext context,
      {bool getTeam = true, empId}) async {
    await DioHelper.getData(
      url: "/emp-salary-advances/entities-operations",
      query: {"emp_id": empId},
      context: context,
    ).then((v) {
      if (v.data['status'] == true) {
        salaryAdvances = v.data['data'];
      }
    }).catchError((error) {
      if (error is DioError) {
        errorMessage =
            error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }

  Future<void> _getEmployeeData(
      {required BuildContext context, required String employeeId}) async {
    try {
      final result = await EmployeeService.getEmployeeData(
          context: context, employeeId: employeeId);
      if (result.success && result.data != null) {
        employee = EmployeeProfileModel.fromJson(result.data?['employee']);
        await getTeamEvaluation(context, employeeId);
      }
    } catch (err, t) {
      debugPrint(
          "error while getting Employee Details  ${err.toString()} at :- $t");
    }
  }

  Future<void> getTeamEvaluation(context, empId) async {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    await DioHelper.getData(
            context: context,
            url: (gCache['employee_profile_id'].toString() == empId.toString())
                ? "/rm_evaluation/v1/evaluation/emp_evaluations"
                : "/rm_evaluation/v1/evaluation/emp_evaluations",
            query:
                (gCache['employee_profile_id'].toString() != empId.toString())
                    ? {"emp_id": empId}
                    : null)
        .then((v) {
      if (v.data['status'] == true) {
        evaluations = v.data['evaluations'];
      } else {
        debugPrint('false');
      }
    }).catchError((error) {
      if (error is DioError) {
        errorMessage =
            error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }

  Future<void> getDailyReports(BuildContext context,
      {required String empId, required bool getTeam}) async {
    try {
      final response = await DailyReportsService.getReports(
        context: context,
        itemsCount: 6,
        page: 1,
        isIncoming: getTeam,
        employeeId: empId,
      );
      if (response.success &&
          response.data != null &&
          response.data!['data'] != null) {
        final List<dynamic> data = response.data!['data'];
        dailyReports = data.map((e) => DailyReportModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching daily reports: $e");
    }
  }

  Future<void> getOvertimeRequestsList(BuildContext context,
      {required String empId, required bool getTeam}) async {
    try {
      final response = getTeam
          ? await RequestsServices.getManagerApprovables(
              context: context,
              type: 'overtime',
              scope: 'team',
              employeesIds: [empId],
              perPage: 6,
            )
          : await RequestsServices.getMyApprovables(
              context: context,
              type: 'overtime',
              perPage: 6,
            );
      if (response.success && response.data != null) {
        final dynamic rawData = response.data!['approvables'] ??
            response.data!['data'] ??
            response.data!['requests'];
        List<dynamic> listData = [];
        if (rawData is Map<String, dynamic> && rawData['data'] is List) {
          listData = rawData['data'];
        } else if (rawData is List) {
          listData = rawData;
        }
        overtimeRequests =
            listData.map((e) => OvertimeRequestModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching overtime requests: $e");
    }
  }

  Future<void> getSalaryAdvanceRequestsList(BuildContext context,
      {required String empId, required bool getTeam}) async {
    try {
      final response = getTeam
          ? await RequestsServices.getManagerApprovables(
              context: context,
              type: 'salary_advance',
              scope: 'team',
              employeesIds: [empId],
              perPage: 6,
            )
          : await RequestsServices.getMyApprovables(
              context: context,
              type: 'salary_advance',
              perPage: 6,
            );
      if (response.success && response.data != null) {
        final dynamic rawData = response.data!['approvables'] ??
            response.data!['data'] ??
            response.data!['requests'];
        List<dynamic> listData = [];
        if (rawData is Map<String, dynamic> && rawData['data'] is List) {
          listData = rawData['data'];
        } else if (rawData is List) {
          listData = rawData;
        }
        salaryAdvanceRequestsList =
            listData.map((e) => SalaryAdvanceRequestModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching salary advances: $e");
    }
  }
}
