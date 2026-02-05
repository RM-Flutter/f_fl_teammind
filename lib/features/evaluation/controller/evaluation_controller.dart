import 'dart:convert';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import '../data/repo/evaluation_repo.dart';
import 'package:flutter/cupertino.dart';

class EvaluationController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List evaluations = [];

  Future<void> getEvaluation(context, empId) async {
    isLoading = true;
    notifyListeners();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>;
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }


    int? queryEmpId;
    if (gCache != null && gCache['employee_profile_id'].toString() != empId.toString()) {
      queryEmpId = int.tryParse(empId.toString());
    }

    final result = await EvaluationRepo.getEvaluations(
      context: context,
      empId: queryEmpId,
    );
    if (result.success && result.data != null) {
      if (result.data!['status'] == true) {
        evaluations = result.data!['evaluations'];
      } else {
        debugPrint('false');
      }
    }
    else {
      errorMessage = result.message ?? 'Something went wrong';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> getEvaluationRequired(context) async {
    isLoading = true;
    notifyListeners();

    final result = await EvaluationRepo.getRequiredEvaluations(
      context: context,
    );

    if (result.success && result.data != null) {
      if (result.data!['status'] == true) {
        evaluations = result.data!['evaluations'];
      } else {
        debugPrint('false');
      }
    } else {
      errorMessage = result.message ?? 'Something went wrong';
    }
    isLoading = false;
    notifyListeners();
  }
}
