import 'package:flutter/material.dart';
import '../../../models/request.model.dart';
import '../../../services/requests.services.dart';

class RequestsByBalanceAndEmployeeIdViewModel extends ChangeNotifier {
  bool isLoading = true;
  List<RequestModel>? requests;
  Future<void> initializeRequestByTypeIdAndEmpIdModal(
      {required BuildContext context,
      required String? requestId,
      required mine,
      required bool latestRequestsWithoutRequestId,
      required String empId}) async {
    updateLoadingStatus(laodingValue: true);
    await _getRequestByTypeIdAndEmployeeId(
        context: context,
        mine: mine,
        requestTypeId: requestId,
        employeeId: empId,
        latestRequestsWithoutRequestId: latestRequestsWithoutRequestId);
    updateLoadingStatus(laodingValue: false);
  }

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }

  Future<void> _getRequestByTypeIdAndEmployeeId(
      {required BuildContext context,
      required String? requestTypeId,
      required bool latestRequestsWithoutRequestId,
      String? employeeId,
        required mine,
      }) async {
    print("mine --> ${mine}");
    try {
      final result =
          await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
              context: context,
              requestTypeId:
                  latestRequestsWithoutRequestId == true ? null : requestTypeId,
              reqType: mine == "me" ? GetRequestsTypes.mine: mine == "team"? GetRequestsTypes.myTeam : GetRequestsTypes.allCompany,
              page: latestRequestsWithoutRequestId == true ? 1 : null,
              empIds: employeeId?.toString());
      if (result.success && result.data != null) {
        var requestsData = result.data?['requests'] as List<dynamic>?;
        requests = requestsData
            ?.map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (err, t) {
      debugPrint(
          "error while getting Request by type id and employee id${err.toString()} at :- $t");
    }
  }
}
