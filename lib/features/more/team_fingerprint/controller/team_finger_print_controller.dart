import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'something_went_wrong'.tr();
      } else {
        errorMessage = AppErrorReporter.safeMessage(error);
      }
    });
  }
}