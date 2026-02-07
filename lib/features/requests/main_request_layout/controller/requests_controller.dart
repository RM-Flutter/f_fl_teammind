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
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  var rulesMessage;
  Future<void> initializeRequestsScreen(
      {required BuildContext context,
      required GetRequestsTypes requestsType,empIds,from,status, to, requestTypeId, depId,  bool loadMore = false}) async {
    await _getAllUserRequests(context: context, requestType: requestsType, loadMore: loadMore,
    to:to ,from:from, requestTypeId: requestTypeId,empIds: empIds, depId: depId, status: status
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
      // نفس القوائم الأصلية، تتفضى فقط في أول تحميل
      if (requestType == GetRequestsTypes.mine) requests!.clear();
      if (requestType == GetRequestsTypes.myTeam) myTeamRequests!.clear();
      if (requestType == GetRequestsTypes.otherDepartment) otherDepartmentRequestModel!.clear();
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      final result = await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
        page: currentPage,
        context: context,
        reqType: requestType,
        empIds: empIds ?? '',
        requestTypeId: requestTypeId ?? "",
        from: from ?? "",
        to: to ?? "",
        depId: depId ?? "",
        status: status ?? "",
      );

      if (result.success && result.data != null && result.data?.isNotEmpty == true) {
        var requestsData = result.data?['requests'] as List<dynamic>?;
        rulesMessage = result.data?['rules_message'] ?? "";

        if (requestsData == null || requestsData.isEmpty) {
          hasMore = false;
        } else {
          // 🧠 خطوة جديدة: التأكد إن الصفحة الجديدة مش مكررة أو فاضية
          List<String> newIds = requestsData
              .map((e) => (e['id'] ?? e['requestId'] ?? '').toString())
              .toList();

          List<String> oldIds = [];
          if (requestType == GetRequestsTypes.mine) {
            oldIds = requests!.map((e) => e.id.toString()).toList();
          } else if (requestType == GetRequestsTypes.myTeam) {
            oldIds = myTeamRequests!.map((e) => e.id.toString()).toList();
          } else if (requestType == GetRequestsTypes.otherDepartment) {
            oldIds = otherDepartmentRequestModel!.map((e) => e.id.toString()).toList();
          }

          final allDuplicate = newIds.every((id) => oldIds.contains(id));
          if (allDuplicate) {
            debugPrint("⚠️ الصفحة $currentPage رجعت نفس البيانات — تم تجاهلها");
            hasMore = false;
            isLoading = false;
            isLoadingMore = false;
            notifyListeners();
            return;
          }

          // نفس منطقك الأصلي 100%
          if (requestType == GetRequestsTypes.mine) {
            print("my_requests page $currentPage Done");
            final newItems = requestsData
                .map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
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
          }

          if (requestType == GetRequestsTypes.myTeam) {
            print("team_requests page $currentPage Done");
            final newItems = requestsData
                .map((item) => MyTeamRequestModel.fromJson(item as Map<String, dynamic>))
                .where((newReq) => !myTeamRequests!.any((oldReq) => oldReq.id == newReq.id))
                .toList();

            if (newItems.isEmpty) {
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

            if (newItems.isEmpty) {
              debugPrint("⚠️ الصفحة $currentPage لم تحتوي على عناصر جديدة");
              hasMore = false;
              isLoading = false;
              isLoadingMore = false;
              notifyListeners();
              return;
            }

            otherDepartmentRequestModel!.addAll(newItems);
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
        return 'ALL COMPANY REQUESTS';
      case GetRequestsTypes.myTeam:
        return AppStrings.teamRequests.tr().toUpperCase();
      case GetRequestsTypes.otherDepartment:
        return AppStrings.otherDepartmentRequests.tr().toUpperCase();
      default:
        return AppStrings.myRequests.tr().toUpperCase();
    }
  }
}
