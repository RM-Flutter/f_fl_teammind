import 'dart:convert';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/evaluation/shared/widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:app_test/features/more/team_fingerprint/controller/team_finger_print_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';



class TeamFingerprintScreen extends StatefulWidget {
  final String? empId;
  final String? empName;
  const TeamFingerprintScreen({super.key, this.empId, this.empName});

  @override
  State<TeamFingerprintScreen> createState() => _TeamFingerprintScreenState();
}

class _TeamFingerprintScreenState extends State<TeamFingerprintScreen> {
  late final TeamFingerPrintViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = TeamFingerPrintViewModel();
    viewModel.getEmployees(context: context);
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
    return ChangeNotifierProvider<TeamFingerPrintViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.teamFingerprint.tr().toUpperCase(),
          onRefresh: () async => await viewModel.getEmployees(context: context),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100.w : double.infinity
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.s12.r),
                child: SingleChildScrollView(
                  child: Consumer<TeamFingerPrintViewModel>(
                      builder: (context, viewModel, child) => viewModel.isLoading
                          ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                          : viewModel.employees?.isEmpty == true ||
                          viewModel.employees == null
                          ? NoExistingPlaceholderScreen(
                          height: 0.6.sh,
                          title: AppStrings.noEmployeesFounded.tr())
                          : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListView.separated(
                                reverse: false,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final totalPoints = viewModel.employees![index]['totalPoints'];
                                  final gainedPoints = viewModel.employees![index]['gainedPoints'];

                                  String percentage;
                                  if (totalPoints != null && gainedPoints != null && gainedPoints != 0) {
                                    percentage = "${((gainedPoints / totalPoints) * 100).toStringAsFixed(1)}%";
                                  } else {
                                    percentage = "0%"; // or any fallback value like "0", "Error", etc.
                                  }
                                  return defaultTeamEmp(
                                    context,
                                    viewModel.employees[index]['name'],
                                    viewModel.employees[index]['department'],
                                    (viewModel.employees[index]['working_hours_type'] == "according_hours_count")? "${viewModel.employees[index]['working_hours']['daily_working_hours']} ${AppStrings.hours.tr()}":
                                    (viewModel.employees[index]['working_hours'] != null && (viewModel.employees[index]['working_hours']['working_hours_from_start'] != null || viewModel.employees[index]['working_hours']['working_hours_from_end'] != null|| viewModel.employees[index]['working_hours']['working_hours_from'] != null || viewModel.employees[index]['working_hours']['working_hours_to'] != null))?
                                    "${AppStrings.from.tr()} ${viewModel.employees[index]['working_hours']['working_hours_from_start']?.toString() ?? viewModel.employees[index]['working_hours']['working_hours_from']?.toString() ?? "0"} ${AppStrings.to.tr()} ${viewModel.employees[index]['working_hours']['working_hours_from_end']?.toString()??viewModel.employees[index]['working_hours']['working_hours_to']?.toString() ?? "0"}": "",
                                    onTap: ()async{
                                      await context.pushNamed(AppRoutes.fingerprintView.name,
                                          pathParameters: {
                                            'id' : viewModel.employees[index]['id'].toString(),
                                            'name' : viewModel.employees[index]['name'],
                                            'lang': context.locale.languageCode
                                          });
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) => SizedBox(height: 15.h,),
                                itemCount: viewModel.employees!.length)
                          ])),
                ),
              ),
            ),
          )),
    );
  }
  Widget defaultTeamEmp(context, t1, t2, t3, {onTap})=>InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: AppSizes.s10.h),
      padding: EdgeInsets.symmetric(
          vertical: AppSizes.s12.h, horizontal: AppSizes.s10.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.s8.r),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t1,style: AppStyles.darkHeading(context).copyWith(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          gapH8,
          Text(t2 != null ?"${t2} - ${t3}" : "${AppStrings.noDepartment.tr()} - ${t3}",
              style: AppStyles.subtitleContent(context).copyWith(fontWeight: FontWeight.w400, fontSize: 12.sp)),

        ],
      ),
    ),
  );
}
