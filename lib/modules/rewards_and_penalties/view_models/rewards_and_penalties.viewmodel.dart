import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rmemp/modules/rewards_and_penalties/models/reward_and_penalty_team.model.dart';
import '../../../constants/user_consts.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/settings.service.dart';
import '../../../models/settings/user_settings.model.dart';
import '../models/reward_and_penalty.model.dart';
import '../services/rewards_and_penalties.service.dart';

class RewardsAndPenaltiesViewModel extends ChangeNotifier {
  List<RewardAndPenaltyModel>? rewardsAndPenalties;
  List<RewardAndPenaltyModelTeam>? rewardsAndPenaltiesTeam;
  UserSettingsModel? userSettings;
  bool isLoading = true;

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializeRewardsAndPenaltiesListScreen(
      {required BuildContext context, required String? empId}) async {
    updateLoadingStatus(laodingValue: true);
    var jsonString;
    var gCache;
    UserSettingsModel? userSettingsModel;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    userSettings = userSettingsModel;
    await _getRewardsAndPenalties(context: context, empId: empId);
    await _getRewardsAndPenaltiesTeam(context: context, empId: empId);
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> _getRewardsAndPenalties(
      {required BuildContext context, String? empId}) async {
    try {
      final result =
          await RewardsAndPenaltiesService.getRewardsAndPenaltiesList(
              context: context, empId: empId, getTeam: false);
      if (result.success && result.data != null) {
        var rewardsAndPenaltiesListData =
            result.data?['data'] as List<dynamic>?;
        rewardsAndPenalties = rewardsAndPenaltiesListData
            ?.map((item) =>
                RewardAndPenaltyModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (err, t) {
      debugPrint(
          "error while getting user rewardsAndPenaltiesListData  list ${err.toString()} at :- $t");
    }
  }
  Future<void> _getRewardsAndPenaltiesTeam(
      {required BuildContext context, String? empId}) async {
    try {
      final result =
          await RewardsAndPenaltiesService.getRewardsAndPenaltiesList(
              context: context, empId: empId, getTeam: true);
      if (result.success && result.data != null) {
        var rewardsAndPenaltiesListData =
            result.data?['data'] as List<dynamic>?;
        rewardsAndPenaltiesTeam = rewardsAndPenaltiesListData
            ?.map((item) =>
            RewardAndPenaltyModelTeam.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (err, t) {
      debugPrint(
          "error while getting user rewardsAndPenaltiesListData  list ${err.toString()} at :- $t");
    }
  }
}
