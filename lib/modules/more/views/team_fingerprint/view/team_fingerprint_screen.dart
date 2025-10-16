import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';
import 'package:rmemp/common_modules_widgets/template_page.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/layout.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/more/views/team_fingerprint/viewmodel/model.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:rmemp/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';


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
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.s12),
            child: SingleChildScrollView(
              child: Consumer<TeamFingerPrintViewModel>(
                  builder: (context, viewModel, child) => viewModel.isLoading
                      ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                      : viewModel.employees?.isEmpty == true ||
                      viewModel.employees == null
                      ? NoExistingPlaceholderScreen(
                      height: LayoutService.getHeight(context) * 0.6,
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
                                onTap: ()async{
                                  await context.pushNamed(AppRoutes.fingerprintView.name,
                                      pathParameters: {
                                        'id' : viewModel.employees[index]['id'].toString(),
                                        'name' : viewModel.employees[index]['name'],
                                        'lang': context.locale.languageCode
                                      });
                                },
                                viewModel.employees[index]['name'],
                                viewModel.employees[index]['department'],
                                (viewModel.employees[index]['working_hours_type'] == "according_hours_count")?
                                "${viewModel.employees[index]['working_hours']['daily_working_hours']} ${AppStrings.hours.tr()}":
                                (viewModel.employees[index]['working_hours'] != null && (viewModel.employees[index]['working_hours']['working_hours_from'] != null || viewModel.employees[index]['working_hours']['working_hours_to'] != null))?
                                "${AppStrings.from.tr()} ${viewModel.employees[index]['working_hours']['working_hours_from']?.toString() ?? "0"} ${AppStrings.to.tr()} ${viewModel.employees[index]['working_hours']['working_hours_to']?.toString() ?? "0"}": "",

                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(height: 15,),
                            itemCount: viewModel.employees!.length)
                      ])),
            ),
          )),
    );
  }
  Widget defaultTeamEmp(context, t1, t2, t3, {onTap})=>InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s10),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.s12, horizontal: AppSizes.s10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.s8),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t1,style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.dark))),
          gapH8,
          Text(t2 != null ?"${t2} - ${t3}" : "${AppStrings.noDepartment.tr()} - ${t3}",
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(AppColors.textC4))),

        ],
      ),
    ),
  );
}
