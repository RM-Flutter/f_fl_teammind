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

class DailyReportsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  final List<DailyReportModel>? reports;
  final String? id;
  final String? empName;
  
  const DailyReportsSectionWidget({super.key, required this.employee, this.reports, this.id, this.empName});

  @override
  Widget build(BuildContext context) {
    if (reports == null || reports!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('no_data_found'.tr()),
        ),
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
          gapH12,
          ListView.separated(
            reverse: false,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final report = reports![index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:  Color(AppColors.buttons).withOpacity(0.06),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100, width: 1.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      context.pushNamed(
                         AppRoutes.dailyReportDetailsScreen.name,
                         pathParameters: {'lang': context.locale.languageCode},
                         extra: report,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:  Color(AppColors.buttons).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:  Icon(Icons.calendar_month_rounded, color: Color(AppColors.buttons), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.createdAt != null 
                                          ? DateFormat('EEEE, dd MMM yyyy', context.locale.languageCode).format(report.createdAt!) 
                                          : "No Date",
                                        style: AppStyles.titleTextContent(context).copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color:  Color(AppColors.secondaryButton),
                                        )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
                            ],
                          ),
                          if (!isIncoming && report.done != null && report.done!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 12),
                              child: Divider(height: 1, color: Colors.grey.shade100),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.green.shade400, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    report.done!, 
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.titleTextContent(context).copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ] else if (isIncoming && employee?.department != null && employee!.department!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 12),
                              child: Divider(height: 1, color: Colors.grey.shade100),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.business_rounded, color: Colors.blue.shade400, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    employee!.department!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.titleTextContent(context).copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemCount: reports!.length <= 5 ? reports!.length : 5,
          ),
          if (reports!.isNotEmpty) const SizedBox(height: 24),
          if (reports!.isNotEmpty)
            Center(
              child: CustomElevatedButton(
                backgroundColor:  Color(AppColors.secondaryButton),
                titleSize: AppSizes.s12,
                title: 'viewAll'.tr().toUpperCase(),
                onPressed: () async {
                  final provider = Provider.of<app_test_reports_provider.DailyReportsProvider>(context, listen: false);
                  final myIdStr = CacheHelper.getString("US1");
                  final myId = myIdStr != null && myIdStr.isNotEmpty ? json.decode(myIdStr)['employee_profile_id'].toString() : '';
                  final isIncoming = (id?.toString() != myId);
                  provider.isForDepartment = isIncoming;
                  if (isIncoming) {
                    provider.incomingFilters['empId'] = id?.toString();
                    provider.incomingFilters['empName'] = empName?.toString();
                  }
                  await context.pushNamed(
                    AppRoutes.dailyReportsListScreen.name,
                    pathParameters: {
                      'lang': context.locale.languageCode,
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
