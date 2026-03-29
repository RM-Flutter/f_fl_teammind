import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/payrolls_list_controller.dart';
import 'widgets/payroll_list_item_widget.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/features/payrolls/shared/models/payroll_model.dart';


class PayrollsListScreen extends StatefulWidget {
  final String? empId;
  final String? empName;
  const PayrollsListScreen({super.key, this.empId, this.empName});

  @override
  State<PayrollsListScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<PayrollsListScreen> {
  late final PayrollsListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PayrollsListViewModel();
    viewModel.initializePayrollsListScreen(
        context: context, empId: widget.empId);
  }

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<PayrollsListViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          bottomAppbarWidget: widget.empId != null &&
                  widget.empId?.isNotEmpty == true &&
                  widget.empName != null &&
                  widget.empName?.isNotEmpty == true &&
                  viewModel.userSettings?.userId.toString() != widget.empId
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(AppSizes.s40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s12, vertical: AppSizes.s6),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        widget.empName!,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.dark),
                            fontSize: AppSizes.s20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : null,
          title: AppStrings.payrolls.tr(),
          onRefresh: () async => await viewModel.initializePayrollsListScreen(
              context: context, empId: widget.empId),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: kIsWeb ? 1100 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s12),
                child: SingleChildScrollView(
                  child: Consumer<PayrollsListViewModel>(
                      builder: (context, viewModel, child) => viewModel.isLoading
                          ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                          : viewModel.payrolls?.isEmpty == true ||
                                  viewModel.payrolls == null
                              ? NoExistingPlaceholderScreen(
                                  height: LayoutService.getHeight(context) * 0.6,
                                  title: AppStrings.noExistingPayrolls.tr())
                              : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            gapH12,
                       if(widget.empName == null) Text(gCache['name'], style:
                        TextStyle(
                            fontWeight: FontWeight.w600,fontSize: 20,
                            color: Color(AppColors.dark)
                        )
                          ,),
                        const SizedBox(height: 20,),
                                  /// general screen message widget for other requests types
                                  // GeneralScreenMessageWidget(
                                  //     screenId: '/payrolls'),
                                  ...viewModel.payrolls!.map((PayrollModel payroll) =>
                                      PayrollListItemWidget(payroll: payroll))
                                ])),
                ),
              ),
            ),
          )),
    );
  }
}
