import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/settings/user_settings.model.dart';
import '../models/employee_profile.model.dart';
import '../services/employee.service.dart';

class EmployeeDetailsViewModel extends ChangeNotifier {
  EmployeeProfileModel? employee;
  UserSettingsModel? currentUserSettings;
  bool isLoading = true;
  String? errorMessage;
  List? evaluations = [];
  List? salaryAdvances = [];
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
    await getSaleryAdvance(context, getTeam: getTeam, empId: employeeId);
    await _getEmployeeData(context: context, employeeId: employeeId);
    updateLoadingStatus(laodingValue: false);
  }
 getSaleryAdvance(BuildContext context, {bool getTeam = true, empId})async{
    isLoading = true;
    notifyListeners();
    await DioHelper.getData(
        url: "/emp-salary-advances/entities-operations",
      query: {
          // "get_team" : getTeam,
          // "with" : "payroll_id",
          "emp_id" : empId
      },
      context: context,
    ).then((v){
      if(v.data['status'] == true){
        salaryAdvances = v.data['data'];
        isLoading = false;
        notifyListeners();
      }
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
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
  getTeamEvaluation(context, empId){
    isLoading = true;
    notifyListeners();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    print("EMD ID IS --> ${empId.toString()}");
    print("EMD ID TWO IS --> ${gCache['employee_profile_id'].toString()}");
    DioHelper.getData(
      context: context,
        url: (gCache['employee_profile_id'].toString() == empId.toString())? "/rm_evaluation/v1/evaluation/emp_evaluations":"/rm_evaluation/v1/evaluation/emp_evaluations",
        query: (gCache['employee_profile_id'].toString() != empId.toString())?{
          "emp_id" : empId
        }: null
        ).then((v){
          if(v.data['status'] == true){
            evaluations = v.data['evaluations'];
          }else{
            print('false');
          }
          isLoading = false;
          notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }
}
