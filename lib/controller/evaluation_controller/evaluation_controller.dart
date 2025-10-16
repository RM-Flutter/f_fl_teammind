import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';

class EvaluationViewModel extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  List evaluations = [];
  getEvaluation(context, empId){
    isLoading = true;
    notifyListeners();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
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
  getEvaluationRequired(context){
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
        context: context,
        url: "/rm_evaluation/v1/evaluation/required_evaluations",
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