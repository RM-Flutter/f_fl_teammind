import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/models/requests_model.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/features/home/data/models/my_team_request_model.dart';
import 'package:app_test/features/home/data/models/other_departments_request.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class RequestsViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<RequestModel>? requests;
  List<MyTeamRequestModel>? myTeamRequests;
  List<OtherDepartmentRequestModel>? otherDepartmentRequestModel;
  List<OtherDepartmentRequestModel>? allCompanyRequests;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  var rulesMessage;

  Future<void> initializeRequestsScreen(
      {required BuildContext context,
        required GetRequestsTypes requestsType, empIds, from, status, to, requestTypeId, depId,
        bool loadMore = false}) async {
    await _getAllUserRequests(
      context: context,
      requestType: requestsType,
      loadMore: loadMore,
      to: to,
      from: from,
      requestTypeId: requestTypeId,
      empIds: empIds,
      depId: depId,
      status: status,
    );
    updateLoadingStatus(laodingValue: false);
  }

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> _getAllUserRequests({
    required BuildContext context,
    required GetRequestsTypes requestType,
    empIds,
    requestTypeId,
    from,
    to,
    depId,
    status,
    bool loadMore = false,
  }) async {
    debugPrint("🟡 isLoading: $isLoading, isLoadingMore: $isLoadingMore, loadMore: $loadMore");
    isLoading = isLoading;
    isLoadingMore = isLoadingMore;
    if (isLoading || isLoadingMore) return;

    if (!loadMore) {
      // أول تحميل فقط
      isLoading = true;
      currentPage = 1;
      hasMore = true;
      requests ??= [];
      myTeamRequests ??= [];
      otherDepartmentRequestModel ??= [];
      allCompanyRequests ??= [];
      // نفس القوائم الأصلية، تتفضى فقط في أول تحميل
      if (requestType == GetRequestsTypes.mine) requests!.clear();
      if (requestType == GetRequestsTypes.myTeam) myTeamRequests!.clear();
      if (requestType == GetRequestsTypes.otherDepartment) otherDepartmentRequestModel!.clear();
      if (requestType == GetRequestsTypes.allCompany) allCompanyRequests!.clear();
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      // ─── NEW: Employee "mine" tab → unified Approvals endpoint ───────────
      if (requestType == GetRequestsTypes.mine) {
        // Convert single empId string → List<String> for employees_ids[]
        final List<String>? empIdsList =
            (empIds != null && empIds.toString().isNotEmpty) ? [empIds.toString()] : null;
        // Convert single depId string → List<String> for department_ids[]
        final List<String>? depIdsList =
            (depId != null && depId.toString().isNotEmpty) ? [depId.toString()] : null;

        final result = await RequestsServices.getMyApprovables(
          context: context,
          type: 'employee_requests',
          employeesIds: empIdsList,
          departmentIds: depIdsList,
          status: (status != null && status.toString().isNotEmpty) ? status.toString() : null,
          dateFrom: (from != null && from.toString().isNotEmpty) ? from.toString() : null,
          dateTo: (to != null && to.toString().isNotEmpty) ? to.toString() : null,
          page: currentPage,
        );

        if (result.success && result.data != null) {
          final approvablesData = result.data?['approvables'] as List<dynamic>?;
          // rules_message: backend will re-add it; keep empty for now
          rulesMessage = result.data?['rules_message'] ?? "";

          if (approvablesData == null || approvablesData.isEmpty) {
            hasMore = false;
          } else {
            final newItems = approvablesData
                .map((item) => RequestModel.fromApprovableJson(item as Map<String, dynamic>))
                .where((newReq) => !requests!.any((oldReq) => oldReq.id == newReq.id))
                .toList();

            if (newItems.isEmpty) {
              debugPrint("⚠️ الصفحة $currentPage لم تحتوي على عناصر جديدة");
              hasMore = false;
              isLoading = false;
              isLoadingMore = false;
              notifyListeners();
              return;
            }
            requests!.addAll(newItems);
            currentPage++;
          }
        } else {
          hasMore = false;
        }
        notifyListeners();
        isLoading = false;
        isLoadingMore = false;
        return;
      }

      // ─── OLD endpoint replaced with new unified Approvals API ───
      String scope = '';
      if (requestType == GetRequestsTypes.myTeam) scope = 'team';
      else if (requestType == GetRequestsTypes.otherDepartment) scope = 'other_departments';
      else if (requestType == GetRequestsTypes.allCompany) scope = 'all_company';

      final List<String>? empIdsList =
          (empIds != null && empIds.toString().isNotEmpty) ? [empIds.toString()] : null;
      final List<String>? depIdsList =
          (depId != null && depId.toString().isNotEmpty) ? [depId.toString()] : null;

      final result = await RequestsServices.getManagerApprovables(
        context: context,
        type: 'employee_requests',
        scope: scope,
        employeesIds: empIdsList,
        departmentIds: depIdsList,
        status: (status != null && status.toString().isNotEmpty) ? status.toString() : null,
        dateFrom: (from != null && from.toString().isNotEmpty) ? from.toString() : null,
        dateTo: (to != null && to.toString().isNotEmpty) ? to.toString() : null,
        page: currentPage,
      );

      if (result.success && result.data != null) {
        var requestsData = result.data?['approvables'] as List<dynamic>?;
        rulesMessage = result.data?['rules_message'] ?? "";

        if (requestsData == null || requestsData.isEmpty) {
          hasMore = false;
        } else {
          // 🧠 التأكد إن الصفحة الجديدة مش مكررة أو فاضية
          List<String> newIds = requestsData
              .map((e) => (e['id'] ?? e['requestId'] ?? '').toString())
              .toList();

          List<String> oldIds = [];
          if (requestType == GetRequestsTypes.myTeam) {
            oldIds = myTeamRequests!.map((e) => e.id.toString()).toList();
          } else if (requestType == GetRequestsTypes.otherDepartment) {
            oldIds = otherDepartmentRequestModel!.map((e) => e.id.toString()).toList();
          } else if (requestType == GetRequestsTypes.allCompany) {
            oldIds = allCompanyRequests!.map((e) => e.id.toString()).toList();
          }

          final allDuplicate = newIds.every((id) => oldIds.contains(id));
          if (allDuplicate && oldIds.isNotEmpty) {
            debugPrint("⚠️ الصفحة $currentPage رجعت نفس البيانات — تم تجاهلها");
            hasMore = false;
            isLoading = false;
            isLoadingMore = false;
            notifyListeners();
            return;
          }

          if (requestType == GetRequestsTypes.myTeam) {
            print("team_requests page $currentPage Done");
            final newItems = requestsData
                .map((item) => MyTeamRequestModel.fromJson(item as Map<String, dynamic>))
                .where((newReq) => !myTeamRequests!.any((oldReq) => oldReq.id == newReq.id))
                .toList();

            if (newItems.isEmpty && myTeamRequests!.isNotEmpty) {
              debugPrint("⚠️ الصفحة $currentPage لم تحتوي على عناصر جديدة");
              hasMore = false;
              isLoading = false;
              isLoadingMore = false;
              notifyListeners();
              return;
            }
            myTeamRequests!.addAll(newItems);
          }

          if (requestType == GetRequestsTypes.otherDepartment) {
            print("otherDepartment_requests page $currentPage Done");
            final newItems = requestsData
                .map((item) => OtherDepartmentRequestModel.fromJson(item as Map<String, dynamic>))
                .where((newReq) => !otherDepartmentRequestModel!.any((oldReq) => oldReq.id == newReq.id))
                .toList();

            if (newItems.isEmpty && otherDepartmentRequestModel!.isNotEmpty) {
              debugPrint("⚠️ الصفحة $currentPage لم تحتوي على عناصر جديدة");
              hasMore = false;
              isLoading = false;
              isLoadingMore = false;
              notifyListeners();
              return;
            }
            otherDepartmentRequestModel!.addAll(newItems);
          }

          if (requestType == GetRequestsTypes.allCompany) {
            print("allCompany_requests page $currentPage Done");
            final newItems = requestsData
                .map((item) => OtherDepartmentRequestModel.fromJson(item as Map<String, dynamic>))
                .where((newReq) => !allCompanyRequests!.any((oldReq) => oldReq.id == newReq.id))
                .toList();

            if (newItems.isEmpty && allCompanyRequests!.isNotEmpty) {
              debugPrint("⚠️ الصفحة $currentPage لم تحتوي على عناصر جديدة");
              hasMore = false;
              isLoading = false;
              isLoadingMore = false;
              notifyListeners();
              return;
            }
            allCompanyRequests!.addAll(newItems);
          }

          currentPage++;
        }

        notifyListeners();
      } else {
        hasMore = false;
      }
    } catch (err, t) {
      notifyListeners();
      debugPrint("error while getting Requests ${err.toString()} at :- $t");
    }
    isLoading = false;
    isLoadingMore = false;
  }

  String getRequestsScreenTitleDependsOnRequestsType(
      {required GetRequestsTypes requestsType}) {
    switch (requestsType) {
      case GetRequestsTypes.allCompany:
        return 'all_company_requests'.tr();
      case GetRequestsTypes.myTeam:
        return AppStrings.teamRequests.tr();
      case GetRequestsTypes.otherDepartment:
        return AppStrings.otherDepartmentRequests.tr();
      default:
        return AppStrings.myRequests.tr();
    }
  }
}
