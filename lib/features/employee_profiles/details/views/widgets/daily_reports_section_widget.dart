import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/daily_reports/models/daily_report_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:provider/provider.dart';
import 'package:app_test/features/daily_reports/controllers/daily_reports_controller.dart' as app_test_reports_provider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

class DailyReportsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  final List<DailyReportModel>? reports;
  final String? id;
  final String? empName;
  
  const DailyReportsSectionWidget({super.key, required this.employee, this.reports, this.id, this.empName});

  @override
  Widget build(BuildContext context) {
    if (reports == null || reports!.isEmpty) {
      return NoExistingPlaceholderScreen(
        compact: true,
        title: AppStrings.noDataFounded.tr(),
      );
    }
    
    final myIdStr = CacheHelper.getString("US1");
    final myId = myIdStr != null && myIdStr.isNotEmpty ? json.decode(myIdStr)['employee_profile_id'].toString() : '';
    final isIncoming = (id?.toString() != myId);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            reverse: false,
            shrinkWrap: true,
            clipBehavior: Clip.none,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final report = reports![index];
              final dateStr = report.createdAt != null
                  ? DateFormat('EEEE, dd MMM yyyy', context.locale.languageCode)
                      .format(report.createdAt!)
                  : "No Date";
              final subtitleStr = (!isIncoming &&
                      report.done != null &&
                      report.done!.isNotEmpty)
                  ? report.done!
                  : (isIncoming &&
                          employee?.department != null &&
                          employee!.department!.isNotEmpty)
                      ? employee!.department!
                      : '';
              final accentColor = Color(AppColors.buttons);

              return AppCard(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.dailyReportDetailsScreen.name,
                    pathParameters: {'lang': context.locale.languageCode},
                    extra: report,
                  );
                },
                child: Row(
                  children: [
                    AppCardLeadingAvatar(
                      icon: Icons.calendar_month_rounded,
                      borderColor: accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.heading(context),
                          ),
                          if (subtitleStr.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitleStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.subtitleContent(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppStatusBadge(
                      label: AppStrings.dailyReports.tr(),
                      color: accentColor,
                      icon: Icons.description_outlined,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.cardGap),
            itemCount: reports!.length <= 5 ? reports!.length : 5,
          ),
          if (reports!.isNotEmpty) const SizedBox(height: 24),
          if (reports!.isNotEmpty)
            Center(
              child: CustomElevatedButton(
                backgroundColor:  Color(AppColors.secondaryButton),
                titleSize: AppSizes.s12,
                title: 'viewAll'.tr(),
                onPressed: () async {
                  final myIdStr = CacheHelper.getString("US1");
                  final myId = myIdStr != null && myIdStr.isNotEmpty ? json.decode(myIdStr)['employee_profile_id'].toString() : '';
                  final isIncoming = (id?.toString() != myId);
                  
                  await context.pushNamed(
                    AppRoutes.dailyReportsListScreen.name,
                    pathParameters: {
                      'lang': context.locale.languageCode,
                    },
                    extra: {
                      "isIncoming": isIncoming,
                      "empId": id?.toString(),
                      "empName": empName?.toString(),
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
