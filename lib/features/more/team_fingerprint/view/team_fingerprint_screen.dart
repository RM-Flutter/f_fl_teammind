import 'package:app_test/core/widgets/app_adaptive_wrap.widget.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
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
import 'package:app_test/core/constants/app_design.dart';

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
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<TeamFingerPrintViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.teamFingerprint.tr(),
          onRefresh: () async => await viewModel.getEmployees(context: context),
          body: Center(
            child: ConstrainedBox(
              constraints: LayoutService.contentConstraints(context),
              child: Padding(
                padding: AppSpacing.pageAll,
                child: SingleChildScrollView(
                  child: Consumer<TeamFingerPrintViewModel>(
                      builder: (context, viewModel, child) => viewModel
                              .isLoading
                          ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget(
                              padding: EdgeInsets.zero)
                          : viewModel.employees?.isEmpty == true ||
                                  viewModel.employees == null
                              ? NoExistingPlaceholderScreen(
                                  height: 0.6.sh,
                                  title: AppStrings.noEmployeesFounded.tr())
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                      AppAdaptiveWrap(
                                        children: List.generate(
                                            viewModel.employees!.length,
                                            (index) {
                                          final totalPoints = viewModel
                                              .employees![index]['totalPoints'];
                                          final gainedPoints =
                                              viewModel.employees![index]
                                                  ['gainedPoints'];

                                          String percentage;
                                          if (totalPoints != null &&
                                              gainedPoints != null &&
                                              gainedPoints != 0) {
                                            percentage =
                                                "${((gainedPoints / totalPoints) * 100).toStringAsFixed(1)}%";
                                          } else {
                                            percentage =
                                                "0%"; // or any fallback value like "0", "Error", etc.
                                          }
                                          return defaultTeamEmp(
                                            context,
                                            viewModel.employees[index]['name'],
                                            viewModel.employees[index]
                                                ['department'],
                                            (viewModel.employees[index][
                                                        'working_hours_type'] ==
                                                    "according_hours_count")
                                                ? "${viewModel.employees[index]['working_hours']['daily_working_hours']} ${AppStrings.hours.tr()}"
                                                : (viewModel.employees[index][
                                                            'working_hours_type'] ==
                                                        "shifts")
                                                    ? AppStrings.shifts.tr()
                                                    : (viewModel.employees[index][
                                                                    'working_hours'] !=
                                                                null &&
                                                            (viewModel.employees[index]['working_hours']['working_hours_from_start'] != null ||
                                                                viewModel.employees[index]['working_hours']['working_hours_from_end'] !=
                                                                    null ||
                                                                viewModel.employees[index]['working_hours']['working_hours_from'] !=
                                                                    null ||
                                                                viewModel.employees[index]['working_hours']
                                                                        ['working_hours_to'] !=
                                                                    null))
                                                        ? "${AppStrings.from.tr()} ${viewModel.employees[index]['working_hours']['working_hours_from_start']?.toString() ?? viewModel.employees[index]['working_hours']['working_hours_from']?.toString() ?? "0"} ${AppStrings.to.tr()} ${viewModel.employees[index]['working_hours']['working_hours_from_end']?.toString() ?? viewModel.employees[index]['working_hours']['working_hours_to']?.toString() ?? "0"}"
                                                        : "",
                                            onTap: () async {
                                              await context.pushNamed(
                                                  AppRoutes
                                                      .fingerprintView.name,
                                                  pathParameters: {
                                                    'id': viewModel
                                                        .employees[index]['id']
                                                        .toString(),
                                                    'name': viewModel
                                                            .employees[index]
                                                        ['name'],
                                                    'lang': context
                                                        .locale.languageCode
                                                  });
                                            },
                                          );
                                        }),
                                      )
                                    ])),
                ),
              ),
            ),
          )),
    );
  }

  /// "From 07:00:00 To 03:00:00" -> "From 07:00 To 03:00" (seconds are noise on a list row).
  String _trimSeconds(String v) =>
      v.replaceAllMapped(RegExp(r'(\d{1,2}:\d{2}):\d{2}'), (m) => m.group(1)!);

  Widget defaultTeamEmp(context, t1, t2, t3, {onTap}) {
    final dept = (t2 != null && t2.toString().trim().isNotEmpty)
        ? t2.toString().trim()
        : AppStrings.noDepartment.tr();
    final hours = _trimSeconds((t3 ?? '').toString().trim());
    return AppCard.listItem(
      context: context,
      title: t1?.toString() ?? '',
      subtitle: hours.isEmpty ? dept : '$dept · $hours',
      avatarInitialsText: t1?.toString(),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Color(AppColors.buttons),
      ),
      onTap: onTap,
    );
  }
}
