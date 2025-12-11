import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/profiles/views/widgets/employee_details_loading.widget.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/layout.service.dart';
import '../../../models/request.model.dart';
import '../../../utils/modal_sheet_helper.dart';
import '../view_models/request_details.viewmodel.dart';
import 'widgets/modals/management_response.modal.dart';
import 'widgets/custom_request_details_button.widget.dart';
import 'widgets/custom_tabbar_view.widget.dart';
import 'widgets/request_details_header_widget.dart';

class RequestDetailsScreen extends StatelessWidget {
  final request;
  final requestType;
  const RequestDetailsScreen({super.key, required this.request, this.requestType});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<RequestDetailsViewModel>(
      create: (_) => RequestDetailsViewModel()..initializeRequestDetails(context: context)..getOneRequest(context, request,),
      child: Consumer<RequestDetailsViewModel>(
        builder: (context, viewModel, child) {
          var jsonString;
          var gCache;
          jsonString = CacheHelper.getString("US1");
          if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
            gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
            UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
          }
          if ((viewModel.requestModel != null)) {
            return Column(
            children: [
              RequestDetailsHeaderWidget(
                uId: viewModel.userSettings?.empId,
                rId:viewModel.requestModel!.employeeId,
                height: kIsWeb? AppSizes.s240:AppSizes.s300,
                request: viewModel.requestModel!,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : double.infinity
                    ),
                    child: CustomTabbarViewRequestDetails(request: viewModel.requestModel!),
                  ),
                ),
              ),
              // Add extra spacing between tabs and buttons on web only
              if (kIsWeb) SizedBox(height: AppSizes.s40),
              if ((viewModel.userSettings?.empId == viewModel.requestModel!.employeeId &&
              viewModel.requestModel!.employeeId != null &&
                  viewModel.userSettings?.empId != null))
              // Case  : the current request is my request
                (viewModel.requestModel!.status == 'waiting_seen' ||
                    viewModel.requestModel!.status == 'waiting' ||
                    viewModel.requestModel!.status == 'waiting_cancel' ||
                    viewModel.requestModel!.status == 'approved' ||viewModel.requestModel!.status == 'refused' ||
                    viewModel.requestModel!.status == 'canceled')
                    ? Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: kIsWeb ? 1100 : double.infinity
                        ),
                        child: Container(
                          height: kIsWeb? 40 : null,
                          alignment: Alignment.topCenter,
                                          padding: EdgeInsets.symmetric(
                          vertical: kIsWeb ? AppSizes.s1 : AppSizes.s6,
                          horizontal: AppSizes.s8),
                                          margin: EdgeInsets.all(kIsWeb ? AppSizes.s6 : AppSizes.s8),
                                          width: LayoutService.getWidth(context),
                                          decoration: BoxDecoration(
                          color: const Color(AppColors.dark),
                          borderRadius: BorderRadius.circular(AppSizes.s50)),
                                          child: Row(children: [
                        if (viewModel.requestModel!.status == 'waiting_seen' ||viewModel.requestModel!.status == 'waiting_cancel' ||
                            viewModel.requestModel!.status == 'waiting') ...[
                          CustomRequestDetailsButton(
                            title: AppStrings.askRemember.tr(),
                            onPressed: () async =>
                            await viewModel.askToRemember(
                                context: context,
                                requestId: viewModel.requestModel!.id?.toString()),
                          ),
                          gapW8,
                          CustomRequestDetailsButton(
                            title: AppStrings.askIgnore.tr(),
                            onPressed: () async => await viewModel.askToIgnore(
                                context: context,
                                requestId: viewModel.requestModel!.id?.toString()),
                          ),
                        ],
                        if ((viewModel.requestModel!.status == 'approved' || viewModel.requestModel!.status == 'canceled'|| viewModel.requestModel!.status == 'refused')) ...[
                          gapW8,
                          CustomRequestDetailsButton(
                              title: AppStrings.complaint.tr(),
                              onPressed: () async => context.pushNamed(
                                  AppRoutes.newComplainScreen.name,
                               pathParameters: {'lang': context.locale.languageCode,}
                              )
                              // await viewModel.askToComplain(
                              //     context: context,
                              //     requestId: request?.toString())
                          )
                        ]
                                          ]),
                                        ),
                      ),
                    )
                    : const SizedBox.shrink()
              else
              // Case: the current request not my request [Manager || Team leader case]
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : double.infinity
                    ),
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.symmetric(
                          vertical: kIsWeb ? AppSizes.s4 : AppSizes.s6, 
                          horizontal: AppSizes.s8),
                      margin: EdgeInsets.all(kIsWeb ? AppSizes.s6 : AppSizes.s8),
                      width: LayoutService.getWidth(context),
                      decoration: BoxDecoration(
                          color: const Color(AppColors.dark),
                          borderRadius: BorderRadius.circular(AppSizes.s50)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        if (viewModel.requestModel!.employeeId != null) ...[
                          // case: the current user is Manager
                          CustomRequestDetailsButton(
                              title: AppStrings.statistics.tr(),
                              onPressed: () async =>
                              await viewModel.showAndGetEmployeeStatistics(
                                  context, viewModel.requestModel!.employeeId.toString(), type: requestType)),
                          gapW8,
                        ],
                        if ((viewModel.requestModel!.status == 'waiting_seen' ||viewModel.requestModel!.status == 'waiting_cancel' ||
                            viewModel.requestModel!.status == 'waiting') &&
                            viewModel.requestModel!.id != null)
                          CustomRequestDetailsButton(
                            title: AppStrings.managementResponse.tr(),
                            onPressed: () async =>
                            await ModalSheetHelper.showModalSheet(
                                context: context,viewProfile: false,
                                modalContent: ManagementResponseModal(
                                  requestId: request.toString(),
                                ),
                                title: AppStrings.managementResponse.tr(),
                                height: (LayoutService.getHeight(context) * 0.5)),
                          )
                      ]),
                    ),
                  ),
                )
            ],
                      );
          } else {
            return const EmployeeDetailsLoadingWidget();
          }
        },
      ),
    ));
  }
}
