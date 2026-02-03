import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../common_modules_widgets/loading_page.widget.dart';
import '../../../../common_modules_widgets/request_card.widget.dart';
import '../../../../constants/app_strings.dart';
import '../../../../services/requests.services.dart';
import '../../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../viewmodels/requests_by_balance_empid.viewmodel.dart';

class RequestsByBalanceAndEmployeeIdModal extends StatefulWidget {
  final String employeeId;
  final String empDepartmentId;
  final String? requestTypeId;
  final bool getLatestRequests;
  const RequestsByBalanceAndEmployeeIdModal(
      {super.key,
      required this.employeeId,
      required this.empDepartmentId,
      required this.requestTypeId,
      this.getLatestRequests = false});

  @override
  State<RequestsByBalanceAndEmployeeIdModal> createState() =>
      _RequestsByBalanceAndEmployeeIdModalState();
}

class _RequestsByBalanceAndEmployeeIdModalState
    extends State<RequestsByBalanceAndEmployeeIdModal> {
  late final RequestsByBalanceAndEmployeeIdViewModel viewModel;
  var mine;

  @override
  void initState() {
    super.initState();
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    viewModel = RequestsByBalanceAndEmployeeIdViewModel();
    print(widget.employeeId.toString());
    print(gCache['empId'].toString());
    if(widget.employeeId.toString() == gCache['employee_profile_id'].toString()){
      print(widget.employeeId.toString());
      print(gCache['employee_profile_id'].toString());
      mine = "me";
    }else if(widget.employeeId.toString() != gCache['employee_profile_id'].toString() && (gCache['is_teamleader_in'].isNotEmpty && gCache['is_teamleader_in'].contains(widget.empDepartmentId) == true) ||
        (gCache['is_manager_in'].isNotEmpty && gCache['is_manager_in'].contains(widget.empDepartmentId) == true)){
      mine = "team";
    }else{
      mine = "company";
    }
    viewModel.initializeRequestByTypeIdAndEmpIdModal(
         mine: mine,
        context: context,
        requestId: widget.requestTypeId,
        latestRequestsWithoutRequestId: widget.getLatestRequests,
        empId: widget.employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel,
      child: Consumer<RequestsByBalanceAndEmployeeIdViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              gapH20,
              Consumer<RequestsByBalanceAndEmployeeIdViewModel>(
                  builder: (context, viewModel, child) => viewModel.isLoading
                      ? const LoadingPageWidget()
                      : viewModel.requests == null ||
                              viewModel.requests?.isEmpty == true
                          ? Center(
                              child: NoExistingPlaceholderScreen(
                                  title: AppStrings.thereIsNoRequests.tr()),
                            )
                          : Column(
                              children: viewModel.requests!
                                  .map(
                                    (req) => RequestCard(
                                      request: req,
                                      reqType: GetRequestsTypes.allCompany,
                                    ),
                                  )
                                  .toList())),
            ],
          );
        },
      ),
    );
  }
}
