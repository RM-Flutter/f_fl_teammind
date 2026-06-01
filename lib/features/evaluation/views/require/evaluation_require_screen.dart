import 'dart:convert';

import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/evaluation/controller/evaluation_controller.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart' show AppSizes;

class EvaluationRequireScreen extends StatefulWidget {
  final String? empId;
  final String? empName;
  const EvaluationRequireScreen({super.key, this.empId, this.empName});

  @override
  State<EvaluationRequireScreen> createState() => _EvaluationRequireScreenState();
}

class _EvaluationRequireScreenState extends State<EvaluationRequireScreen> {
  late final EvaluationController viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EvaluationController();
    viewModel.getEvaluationRequired(context);
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
    return ChangeNotifierProvider<EvaluationController>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.evaluationRequest.tr(),
          onRefresh: () async => await viewModel.getEvaluationRequired(context),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100.w : double.infinity
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.s12.w),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if(viewModel.evaluations.isEmpty == true)    CustomElevatedButton(
                          backgroundColor: Color(AppColors.buttons),
                          titleSize: AppSizes.s12.sp,
                          title: AppStrings.myEvaluations.tr().toUpperCase(),
                          onPressed: () async => await context.pushNamed(
                              AppRoutes.evaluationScreen.name,
                              extra: {
                                "empId": gCache['employee_profile_id'].toString(),
                                "begin": const Offset(1.0, 0.0),
                              },
                              pathParameters: {
                                'lang': context.locale.languageCode,
                                // "empName" : "unKnown"
                              })),
                      if(viewModel.evaluations.isEmpty == true)   SizedBox(height: 20.h),
                      Consumer<EvaluationController>(
                          builder: (context, viewModel, child) => viewModel.isLoading
                              ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                              : viewModel.evaluations.isEmpty == true
                              ? NoExistingPlaceholderScreen(
                              height: LayoutService.getHeight(context) * 0.6,
                              title: AppStrings.noExistingEvaluation.tr())
                              : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 20.h),
                                /// general screen message widget for other requests types
                                // GeneralScreenMessageWidget(
                                //     screenId: '/payrolls'),
                                ListView.separated(
                                    reverse: false,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return ProfileTileEvaReq(
                                        createAt: viewModel.evaluations[index]['created_at'],
                                        empName: viewModel.evaluations[index]['employee_name'],
                                        name: gCache['name'],
                                        icon : viewModel.evaluations[index]['done']  == true? Icon(Icons.check_circle_outline_rounded,
                                            color: Colors.green, size: AppSizes.s24.sp) : Icon(Icons.access_time,
                                            color:  const Color(0xff606060), size: AppSizes.s24.sp),
                                        department: viewModel.evaluations[index]['department_name'],
                                        title: "${viewModel.evaluations[index]['title']}",
                                        url: (viewModel.evaluations[index]['submitUrl'] != null)? viewModel.evaluations[index]['submitUrl'].toString() : null,
                                      );
                                    },
                                    separatorBuilder: (context, index) => SizedBox(height: 15.h),
                                    itemCount: viewModel.evaluations.length),

                              ])),

                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
