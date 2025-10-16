import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import '../../../general_services/layout.service.dart';
import '../../../models/request.model.dart';
import '../../../services/requests.services.dart';
import '../../../utils/modal_sheet_helper.dart';
import '../models/summary_report.model.dart';
import '../views/widgets/modals/summary_reports.modal.dart';

class RequestsWithTypeIdViewModel extends ChangeNotifier {
  bool isLoading = true;
  List<RequestModel>? requestsById;
  List<SummaryReportModel>? summaryReports;
  var rulesMessage;
  Future<void> initializeRequestScreenByTypeIdgetRequestsByTypeId(
      {required BuildContext context,
      required String requestTypeId,
        type,
      String? employeeId}) async {
    updateLoadingStatus(laodingValue: true);
    await _getRequestByTypeId(
        context: context, requestTypeId: requestTypeId, employeeId: employeeId, type: type);
    if (employeeId == null) {
      await _getSumaryReports(context: context, requestTypeId: requestTypeId);
    }
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> showSummaryReports({required BuildContext context}) async {
    if (summaryReports == null || summaryReports?.isEmpty == true) return;
    await ModalSheetHelper.showModalSheet(
        context: context,viewProfile: false,
        height: (LayoutService.getHeight(context) * 0.5),
        modalContent: SummaryReportsModal(summaryReports: summaryReports!),
        title: AppStrings.summaryReports.tr());
  }

  Future<void> _getSumaryReports({
    required BuildContext context,
    required String requestTypeId,
  }) async {
    try {
      DioHelper.getData(
         url: "/emp_reports/v1/summary_report",
         context: context,
         query: {
        "request_type_id" : requestTypeId.toString()
      }
      ).then((v){
        if (v.data['status'] == true&& v.data != null) {
          final data = v.data as Map<String, dynamic>;
          final summaryReportsData = data['summary'] as List<dynamic>;
          summaryReports = summaryReportsData
              .map((item) => SummaryReportModel.fromJson(item as Map<String, dynamic>))
              .toList();
          print("summaryReports $summaryReports");
        }
        notifyListeners();
      });
      // final result = await RequestsServices.getSummaryReports(
      //   context: context,
      //   requestTypeId: requestTypeId,
      // );

    } catch (err, t) {
      debugPrint(
        "error while getting Summary Reports by type id ${err.toString()} at :- $t",
      );
    }
  }


  Future<void> _getRequestByTypeId(
      {required BuildContext context,
      required String requestTypeId,
        type,
      String? employeeId}) async {
    // get Request by type id
    try {
      final result =
          await RequestsServices.getRequestsByTypeDependsOnUserPrivileges(
              context: context,
              reqType: type??GetRequestsTypes.mine,
              requestTypeId: requestTypeId,
              empIds: employeeId != null ? employeeId.toString() : null);
      if (result.success && result.data != null) {
        var requestsData = result.data?['requests'] as List<dynamic>?;
        print("RULES IS --> ${result.data?['rules_message']}");
        if(result.data?['rules_message'] != null && result.data?['rules_message'] != "" ){
          rulesMessage = result.data?['rules_message'] ?? "";
          print("RULES IS DONE");
        }
        requestsById = requestsData
            ?.map((item) => RequestModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (err, t) {
      debugPrint(
          "error while getting Request by type id ${err.toString()} at :- $t");
    }
  }

  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }
}
