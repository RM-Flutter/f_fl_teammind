import 'dart:convert';

import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';
import 'package:flutter/material.dart';
import '../../shared/repos/payroll_service.dart';

class PayrollsListViewModel extends ChangeNotifier {
  List<PayrollModel>? payrolls;
  UserSettingsModel? userSettings;

  bool isLoading = true;
  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializePayrollsListScreen(
      {required BuildContext context, required String? empId}) async {
    updateLoadingStatus(laodingValue: true);
    var jsonString;
    UserSettingsModel userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    userSettings = userSettingsModel;
    await _getPayrolls(context: context, empId: empId);
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> _getPayrolls(
      {required BuildContext context, String? empId}) async {
    // get user Payrolls
    try {
      final result = await PayrollRepo.getPayrollsList(
          context: context, empId: empId, withValues: ['user_id']);
      if (result.success && result.data != null) {
        var payrollsListData = result.data?['data'] as List<dynamic>?;
        payrolls = payrollsListData
            ?.map((item) => PayrollModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (err, t) {
      debugPrint(
          "error while getting user payrolls list ${err.toString()} at :- $t");
    }
  }
}
