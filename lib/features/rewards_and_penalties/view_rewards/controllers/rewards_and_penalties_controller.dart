import 'dart:convert';

import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/features/rewards_and_penalties/view_rewards/data/models/reward_and_penalty_team_model.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/routing/app_router.dart';
import '../../../../core/services/backend_services/api_service/dio_api_service/dio.dart';
import '../data/models/reward_and_penalty_model.dart';
import '../data/repos/rewards_and_penalties.service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';

class RewardsAndPenaltiesViewModel extends ChangeNotifier {
  List<RewardAndPenaltyModel>? rewardsAndPenalties;
  List<RewardAndPenaltyModelTeam>? rewardsAndPenaltiesTeam;
  UserSettingsModel? userSettings;
  int currentPersonalPage = 1;
  bool hasMorePersonal = true;
  bool isLoadingMorePersonal = false;

  int currentTeamPage = 1;
  bool hasMoreTeam = true;
  bool isLoadingMoreTeam = false;
  bool isForTeam = false;
  String? currentEmpId;
  
  Future<void> toggleTeamView(bool value, BuildContext context) async {
    isForTeam = value;
    notifyListeners();
    if (isForTeam && (rewardsAndPenaltiesTeam == null || rewardsAndPenaltiesTeam!.isEmpty) && hasMoreTeam) {
      updateLoadingStatus(laodingValue: true);
      await _getRewardsAndPenaltiesTeam(context: context, empId: currentEmpId, page: 1);
      updateLoadingStatus(laodingValue: false);
    } else if (!isForTeam && (rewardsAndPenalties == null || rewardsAndPenalties!.isEmpty) && hasMorePersonal) {
      updateLoadingStatus(laodingValue: true);
      await _getRewardsAndPenalties(context: context, empId: currentEmpId, page: 1);
      updateLoadingStatus(laodingValue: false);
    }
  }

  bool isLoading = true;

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> initializeRewardsAndPenaltiesListScreen(
      {required BuildContext context, required String? empId}) async {
    this.currentEmpId = empId;
    updateLoadingStatus(laodingValue: true);
    currentPersonalPage = 1;
    hasMorePersonal = true;
    currentTeamPage = 1;
    hasMoreTeam = true;
    rewardsAndPenalties = null;
    rewardsAndPenaltiesTeam = null;

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
    
    if (isForTeam) {
      await _getRewardsAndPenaltiesTeam(context: context, empId: empId, page: 1);
    } else {
      await _getRewardsAndPenalties(context: context, empId: empId, page: 1);
    }
    
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> _getRewardsAndPenalties(
      {required BuildContext context, String? empId, int page = 1}) async {
    try {
      final result =
          await RewardsAndPenaltiesRepo.getRewardsAndPenaltiesList(
              context: context, empId: empId, getTeam: false, page: page);
      if (result.success && result.data != null) {
        var rewardsAndPenaltiesListData =
            result.data?['data'] as List<dynamic>?;
        
        final newItems = rewardsAndPenaltiesListData
            ?.map((item) =>
                RewardAndPenaltyModel.fromJson(item as Map<String, dynamic>))
            .toList() ?? [];

        if (page == 1) {
          rewardsAndPenalties = newItems;
        } else {
          rewardsAndPenalties?.addAll(newItems);
        }

        if (newItems.isEmpty) {
          hasMorePersonal = false;
        }
      } else {
        hasMorePersonal = false;
      }
    } catch (err, t) {
      hasMorePersonal = false;
      debugPrint(
          "error while getting user rewardsAndPenaltiesListData  list ${err.toString()} at :- $t");
    }
  }

  Future<void> loadMorePersonal(BuildContext context, String? empId) async {
    if (isLoadingMorePersonal || !hasMorePersonal) return;
    isLoadingMorePersonal = true;
    notifyListeners();

    currentPersonalPage++;
    await _getRewardsAndPenalties(context: context, empId: empId, page: currentPersonalPage);

    isLoadingMorePersonal = false;
    notifyListeners();
  }

  Future<void> _getRewardsAndPenaltiesTeam(
      {required BuildContext context, String? empId, int page = 1}) async {
    try {
      final result =
          await RewardsAndPenaltiesRepo.getRewardsAndPenaltiesList(
              context: context, empId: empId, getTeam: true, page: page);
      if (result.success && result.data != null) {
        var rewardsAndPenaltiesTeamData =
            result.data?['data'] as List<dynamic>?;
        
        final newItems = rewardsAndPenaltiesTeamData
            ?.map((item) => RewardAndPenaltyModelTeam.fromJson(
                item as Map<String, dynamic>))
            .toList() ?? [];

        if (page == 1) {
          rewardsAndPenaltiesTeam = newItems;
        } else {
          rewardsAndPenaltiesTeam?.addAll(newItems);
        }

        if (newItems.isEmpty) {
          hasMoreTeam = false;
        }
      } else {
        hasMoreTeam = false;
      }
    } catch (err, t) {
      hasMoreTeam = false;
      debugPrint(
          "error while getting user rewardsAndPenaltiesListData  list ${err.toString()} at :- $t");
    }
  }

  Future<void> loadMoreTeam(BuildContext context, String? empId) async {
    if (isLoadingMoreTeam || !hasMoreTeam) return;
    isLoadingMoreTeam = true;
    notifyListeners();

    currentTeamPage++;
    await _getRewardsAndPenaltiesTeam(context: context, empId: empId, page: currentTeamPage);

    isLoadingMoreTeam = false;
    notifyListeners();
  }

  Future<void> cancelRewardAndPenalty({required BuildContext context, required int id, String? empId}) async {
    final safeContext = rootNavigatorKey.currentContext ?? context;
    updateLoadingStatus(laodingValue: true);
    try {
      final response = await DioHelper.deleteData(
        url: "/rm_payroll/v1/payroll/penalities-and-rewards/$id",
        context: safeContext,
      );
      if (response.data['status'] == true) {
        AlertsService.success(
          context: safeContext,
          title: 'Success',
          message: response.data['message'] ?? 'Successfully deleted',
        );
        // Refresh the list
        await initializeRewardsAndPenaltiesListScreen(context: safeContext, empId: empId ?? this.currentEmpId);
      } else {
        updateLoadingStatus(laodingValue: false);
      }
    } catch (error) {
      updateLoadingStatus(laodingValue: false);
      debugPrint("Error canceling reward/penalty: $error");
    }
  }
}

