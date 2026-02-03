import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/alert_service/alerts.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/general_services/settings.service.dart';
import 'package:rmemp/models/settings/general_settings.model.dart';
import 'package:rmemp/models/settings/user_settings_2.model.dart';

import '../../constants/user_consts.dart';

class FilterController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? selectEmpId;
  String? selectDepId;
  String? selectReqId;
  Map<String, dynamic>? selectedEmployee;
  Map<String, dynamic>? selectedDepartment;
  Map<String, dynamic>? selectedUsers;
  List<Map<String, dynamic>>? requestsTypes;
  Map<String, dynamic>? selectedType;
  TextEditingController selectedDatecontroller = TextEditingController();
  DateTime? selectedDate;
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> departments = [];
  void getRequestTypes({required BuildContext context}){
    try {
      // Fetch user2Settings data from app settings
      var jsonString;
      var gCache;
      jsonString = CacheHelper.getString("US2");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
        UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache);
        }
      // get user balance from User2Settings
      final userBalance = gCache['balance'];
      // check if the user balance is null || empty then there is no requests types
      if (userBalance == null || userBalance.isEmpty) {
        requestsTypes = [];
        return;
      }
      // Fetch request types from generalSettings and if there is no request types in generalSettings then return requests types with empty list
      final requestsTypesDataFromGeneralSettings =
          UserSettingConst.generalSettingsModel?.requestTypes;
      if (requestsTypesDataFromGeneralSettings == null ||
          requestsTypesDataFromGeneralSettings.isEmpty) {
        requestsTypes = [];
        return;
      }

      // looping on user balance to get the available requests types with considering the the balance and it can be listed or not
      userBalance.forEach((requestId, val) {
        if (requestsTypesDataFromGeneralSettings.containsKey(requestId)) {
          requestsTypes ??= [];
          final original = requestsTypesDataFromGeneralSettings[requestId]?.toJson()
          as Map<String, dynamic>;

          requestsTypes!.add({
            'id': original['id'],
            'title': (CacheHelper.getString("lang") == "ar"
                ? original['title']['ar']
                : original['title']['en'])?.toString() ?? '',
          });
          print("requestsTypes is --> $requestsTypes");
        }
      });
      return;
    } catch (ex, t) {
      debugPrint(
          'Error getting request types ${ex.toString()} at :- ${t.toString()}');
      requestsTypes = [];
    }
  }
  void getEmployees({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
        url: "/emp_requests/v1/employees",
      context: context,
    ).then((value){
      isLoading = false;
      employees = List<Map<String, dynamic>>.from(value.data['employees']);
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
  void getDepartment({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
        url: "/departments/entities-operations",
      context: context,
    ).then((value){
      isLoading = false;
      departments = List<Map<String, dynamic>>.from(value.data['data']);
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
  Future<void> selectDate(BuildContext context) async {
    final String? type = selectedType?['type'];
    if (type == null || type.isEmpty) {
      AlertsService.info(
          context: context,
          message: 'please Select First Type',
          title: 'Information');
      return;
    }
    await _selectDate(context);
    if (selectedDate == null) {
      AlertsService.warning(
          context: context,
          message: 'please select the Date again !',
          title: AppStrings.warning.tr());
      return;
    }
    selectedDatecontroller.text = formatDateTimeRange(selectedDate!);
    notifyListeners();
  }

  /// USED WHEN THE DURATION TYPE IN THE SELECTED REQUEST IS DAYS
  Future<void> _selectDate(BuildContext context) async {
    final newDateRange = await showDatePicker(
        context: context,
        switchToInputEntryModeIcon: const Icon(Icons.add, color: Colors.transparent,),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDate: DateTime.now());
    if (newDateRange == null) return;
    selectedDate = newDateRange;
  }

  String formatDateTimeRange(DateTime date) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    return dateFormatter.format(date);
  }
}