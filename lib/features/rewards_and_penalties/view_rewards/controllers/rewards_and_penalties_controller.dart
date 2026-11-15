import 'dart:convert';

import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/utils/request_scope_helper.dart';
import 'package:flutter/material.dart';

import '../data/models/reward_penalty_approvable_model.dart';
import '../data/repos/rewards_and_penalties.service.dart';

/// List of rewards and penalties through the approval system
/// (type `rewards_and_penalties`): "mine" and "incoming" (team / other
/// departments / all company). Details and actions open `approvableDetails`.
/// Creating a reward or penalty still uses the old payroll endpoint
/// (`add_rewards/`).
class RewardsAndPenaltiesViewModel extends ChangeNotifier {
  List<RewardPenaltyApprovableModel>? personalItems;
  List<RewardPenaltyApprovableModel>? incomingItems;
  UserSettingsModel? userSettings;

  bool isLoadingPersonal = true;
  bool isLoadingIncoming = true;

  int personalCurrentPage = 1;
  bool personalHasMore = true;
  bool personalIsLoadingMore = false;

  int incomingCurrentPage = 1;
  bool incomingHasMore = true;
  bool incomingIsLoadingMore = false;

  bool isIncomingView = false;
  String incomingScope = RequestScopeHelper.defaultIncomingScope;

  /// When opened from an employee profile, the incoming list is filtered to
  /// this employee.
  String? filterEmpId;

  Map<String, String?> personalFilters = {};
  Map<String, String?> incomingFilters = {};

  Map<String, String?> get currentFiltersMap =>
      isIncomingView ? incomingFilters : personalFilters;

  String? get filterEmpName => currentFiltersMap['empName'];
  String? get filterDepId => currentFiltersMap['depId'];
  String? get filterDepName => currentFiltersMap['depName'];
  String? get filterStatus => currentFiltersMap['status'];
  String? get filterFrom => currentFiltersMap['from'];
  String? get filterTo => currentFiltersMap['to'];
  String? get _filterEmp => currentFiltersMap['empId'];

  bool get isLoading => isIncomingView ? isLoadingIncoming : isLoadingPersonal;
  List<RewardPenaltyApprovableModel>? get currentList =>
      isIncomingView ? incomingItems : personalItems;

  void _loadUserSettings() {
    final jsonString = CacheHelper.getString('US1');
    if (jsonString != null && jsonString.isNotEmpty) {
      userSettings = UserSettingsModel.fromJson(
          json.decode(jsonString) as Map<String, dynamic>);
      UserSettingConst.userSettings = userSettings;
    }
  }

  /// Opens the incoming view filtered to one employee (from their profile).
  void openForEmployee({required String empId, String? empName}) {
    filterEmpId = empId;
    isIncomingView = true;
    incomingScope = RequestScopeHelper.defaultIncomingScope;
    incomingFilters['empId'] = empId;
    incomingFilters['empName'] = empName;
  }

  Future<void> initializeScreen(BuildContext context) async {
    _loadUserSettings();
    if (isIncomingView) {
      await getIncoming(context: context);
    } else {
      await getPersonal(context: context);
    }
  }

  void toggleIncomingView(bool value, BuildContext context) {
    isIncomingView = value;
    notifyListeners();
    if (value && incomingItems == null) {
      getIncoming(context: context);
    } else if (!value && personalItems == null) {
      getPersonal(context: context);
    }
  }

  void setIncomingScope(String scope, BuildContext context) {
    incomingScope = scope;
    incomingItems = null;
    notifyListeners();
    getIncoming(context: context);
  }

  void applyFilters(Map<String, String?> filters, BuildContext context) {
    if (isIncomingView) {
      incomingFilters = Map.from(filters);
      getIncoming(context: context);
    } else {
      personalFilters = Map.from(filters);
      getPersonal(context: context);
    }
  }

  void _clear(List<String> keys, BuildContext context) {
    final filters = Map<String, String?>.from(currentFiltersMap);
    for (final k in keys) {
      filters[k] = null;
    }
    applyFilters(filters, context);
  }

  void clearFilterEmp(BuildContext context) => _clear(['empId', 'empName'], context);
  void clearFilterDep(BuildContext context) => _clear(['depId', 'depName'], context);
  void clearFilterDate(BuildContext context) => _clear(['from', 'to'], context);
  void clearFilterStatus(BuildContext context) => _clear(['status'], context);

  List<RewardPenaltyApprovableModel> _parse(Map<String, dynamic>? data) {
    final raw = data?['approvables'] ?? data?['data'];
    final List list = raw is Map && raw['data'] is List
        ? raw['data'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map<String, dynamic>>()
        .map(RewardPenaltyApprovableModel.fromApprovableJson)
        .toList();
  }

  Future<void> getPersonal(
      {required BuildContext context, bool loadMore = false}) async {
    if (loadMore) {
      if (!personalHasMore || personalIsLoadingMore) return;
      personalIsLoadingMore = true;
      personalCurrentPage++;
    } else {
      personalCurrentPage = 1;
      personalHasMore = true;
      isLoadingPersonal = true;
    }
    notifyListeners();

    try {
      final result = await RequestsServices.getMyApprovables(
        context: context,
        type: RewardsAndPenaltiesRepo.approvableType,
        page: personalCurrentPage,
        status: filterStatus,
        dateFrom: filterFrom,
        dateTo: filterTo,
      );
      if (result.success) {
        final items = _parse(result.data);
        if (items.isEmpty) personalHasMore = false;
        if (personalCurrentPage == 1) {
          personalItems = items;
        } else {
          personalItems?.addAll(items);
        }
      } else {
        personalHasMore = false;
        if (!loadMore) personalItems = [];
      }
    } catch (e, t) {
      personalHasMore = false;
      debugPrint('Error fetching my rewards/penalties: $e at $t');
    } finally {
      personalIsLoadingMore = false;
      isLoadingPersonal = false;
      notifyListeners();
    }
  }

  Future<void> getIncoming(
      {required BuildContext context, bool loadMore = false}) async {
    if (loadMore) {
      if (!incomingHasMore || incomingIsLoadingMore) return;
      incomingIsLoadingMore = true;
      incomingCurrentPage++;
    } else {
      incomingCurrentPage = 1;
      incomingHasMore = true;
      isLoadingIncoming = true;
    }
    notifyListeners();

    try {
      final result = await RequestsServices.getManagerApprovables(
        context: context,
        type: RewardsAndPenaltiesRepo.approvableType,
        scope: incomingScope,
        page: incomingCurrentPage,
        employeesIds:
            (_filterEmp != null && _filterEmp!.isNotEmpty) ? [_filterEmp!] : null,
        departmentIds:
            (filterDepId != null && filterDepId!.isNotEmpty) ? [filterDepId!] : null,
        status: filterStatus,
        dateFrom: filterFrom,
        dateTo: filterTo,
      );
      if (result.success) {
        final items = _parse(result.data);
        if (items.isEmpty) incomingHasMore = false;
        if (incomingCurrentPage == 1) {
          incomingItems = items;
        } else {
          incomingItems?.addAll(items);
        }
      } else {
        incomingHasMore = false;
        if (!loadMore) incomingItems = [];
      }
    } catch (e, t) {
      incomingHasMore = false;
      debugPrint('Error fetching incoming rewards/penalties: $e at $t');
    } finally {
      incomingIsLoadingMore = false;
      isLoadingIncoming = false;
      notifyListeners();
    }
  }

  void loadMore(BuildContext context) {
    if (isIncomingView) {
      getIncoming(context: context, loadMore: true);
    } else {
      getPersonal(context: context, loadMore: true);
    }
  }
}
