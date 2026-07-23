import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../../employee_profiles/shared/repos/employee_repo.dart';
import '../models/overtime_request_model.dart';
import '../services/overtime_requests_service.dart';

class OvertimeRequestsProvider extends ChangeNotifier {
  List<OvertimeRequestModel> myRequests = [];
  List<OvertimeRequestModel> teamRequests = [];

  bool isLoading = false;
  bool isActionLoading = false;
  bool isForDepartment = false;

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
    
    fetchRequests(context);
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

  Future<void> fetchRequests(BuildContext context) async {
    isLoading = true;
    notifyListeners();

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
      );
      
      if (response.success && response.data != null && response.data!['requests'] != null) {
        final List<dynamic> requestsData = response.data!['requests'];
        final List<OvertimeRequestModel> allRequests = requestsData.map((e) {
          final model = OvertimeRequestModel.fromJson(e);
          // If name is missing, try to map it from our employee list
          if ((model.employeeName == null || model.employeeName!.isEmpty) && model.employeeProfileId != null) {
            model.employeeName = employeeNames[model.employeeProfileId];
          }
          return model;
        }).toList();

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
           myRequests = allRequests.where((element) => element.employeeProfileId == currentUserId).toList();
           teamRequests = allRequests.where((element) => element.employeeProfileId != currentUserId).toList();
        } else {
           myRequests = allRequests;
           teamRequests = [];
        }

      } else {
        myRequests = [];
        teamRequests = [];
      }
    } catch (e) {
      debugPrint("Error fetching overtime requests: $e");
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
    
    fetchRequests(context);
    notifyListeners();
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
      }
    } catch (e) {
      debugPrint("Error updating duration: $e");
    }
    isActionLoading = false;
    notifyListeners();
    return success;
  }
}
