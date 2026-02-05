import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';

class TeamFingerPrintViewModel extends ChangeNotifier{
  bool isLoading = false;
  String? errorMessage;
  List employees = [];
  getEmployees({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/emp_requests/v1/employees",
      query: {
        "under_my_management" : true
      },
      context: context,
    ).then((value){
      isLoading = false;
      employees = value.data['employees'];
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