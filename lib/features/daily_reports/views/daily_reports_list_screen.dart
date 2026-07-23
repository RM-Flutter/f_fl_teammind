import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../../../../core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../more/notifications/views/widgets/switch_row_notification.dart';
import '../controllers/daily_reports_controller.dart';
import '../models/daily_report_model.dart';
import '../../../../core/widgets/shared_list_filter_widget.dart' as app_test_filter;
import '../../../../core/widgets/active_filters_row_widget.dart';

class DailyReportsListScreen extends StatefulWidget {
  const DailyReportsListScreen({super.key});

  @override
  State<DailyReportsListScreen> createState() => _DailyReportsListScreenState();
}

class _DailyReportsListScreenState extends State<DailyReportsListScreen> {
  late DailyReportsProvider provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<DailyReportsProvider>(context, listen: false);
      if (provider.isManagerOrHr) {
        provider.fetchReports(context, isIncoming: true);
      }
      provider.fetchReports(context);
      setState(() {});
    });
  }

  @override
  void dispose() {
    try {
      provider.resetAllFilters();
    } catch (_) {}
    super.dispose();
  }

  void _deleteReport(BuildContext context, DailyReportModel report,
      DailyReportsProvider provider) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: EdgeInsets.all(AppSizes.s24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade400, size: 36),
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppStrings.deleteReport.tr(),
                    style: AppStyles.heading(context).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.titleTextColor),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    AppStrings.confirmDeleteReport.tr(),
                    style: AppStyles.content(context).copyWith(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            AppStrings.cancel.tr(),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade500,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            AppStrings.delete.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (confirm) {
      await provider.deleteReport(context, report.id.toString());
      if (context.mounted) {
        provider.fetchReports(context);
        if (provider.isManagerOrHr) {
          provider.fetchReports(context, isIncoming: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyReportsProvider>(
      builder: (context, provider, child) {
        return TemplatePage(
          pageContext: context,
          title: AppStrings.dailyReports.tr(),
          routeName: AppRoutes.dailyReportsListScreen.name,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list_rounded, color: Color(AppColors.secondaryButton)),
              onPressed: () async {
                  final result = await showModalBottomSheet<Map<String, String?>>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => app_test_filter.SharedListFilterWidget(
                      showEmployee: provider.isForDepartment,
                      showDepartment: provider.isForDepartment,
                      showDateRange: true,
                      initialFilters: provider.currentFiltersMap,
                    ),
                  );
                if (result != null && context.mounted) {
                  provider.applyFilters(result, context);
                }
              },
            ),
          ],
          floatingActionButton: provider.isManagerOrHr && provider.isForDepartment ? null : FloatingActionButton.extended(
            heroTag: 'add_daily_report',
            backgroundColor: Color(AppColors.buttons),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            onPressed: () {
               context.pushNamed(
                 AppRoutes.addEditDailyReportScreen.name,
                 pathParameters: {'lang': context.locale.languageCode},
               ).then((_) {
                 if (context.mounted) {
                   provider.fetchReports(context);
                   if (provider.isManagerOrHr) provider.fetchReports(context, isIncoming: true);
                 }
               });
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(AppStrings.addReport.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          body: Column(
            children: [
              if (provider.isManagerOrHr) ...[
                SizedBox(height: 10),
                SwitchRowNotification(
                  value: provider.isForDepartment,
                  leftText: AppStrings.personalReports.tr(),
                  rightText: AppStrings.incomingReports.tr(),
                  onChanged: (val) {
                    provider.toggleDepartmentView(val, context);
                  },
                ),
                SizedBox(height: 10),
              ],
              ActiveFiltersRowWidget(
                empName: provider.filterEmpName,
                depName: provider.filterDepName,
                fromDate: provider.filterFrom,
                toDate: provider.filterTo,
                onClearEmp: () => provider.clearFilterEmp(context),
                onClearDep: () => provider.clearFilterDep(context),
                onClearDate: () => provider.clearFilterDate(context),
                onClearStatus: () {},
              ),
              Expanded(
                child: provider.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : provider.isForDepartment
                    ? _buildList(provider.incomingReports, provider, isIncoming: true)
                    : _buildList(provider.personalReports, provider, isIncoming: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<DailyReportModel> list, DailyReportsProvider provider, {required bool isIncoming}) {
    if (list.isEmpty) {
      return RefreshIndicator.adaptive(
        onRefresh: () async {
          await provider.fetchReports(context, isIncoming: isIncoming);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: NoExistingPlaceholderScreen(
            height: 300,
            title: AppStrings.noDataFounded.tr(),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await provider.fetchReports(context, isIncoming: isIncoming);
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: 16, bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildReportCard(item, provider, isIncoming: isIncoming);
        },
      ),
    );
  }

  Widget _buildReportCard(DailyReportModel report, DailyReportsProvider provider, {required bool isIncoming}) {
    String? displayName = report.employeeProfile?.name;
    // Only the owner can edit their own reports (which are in the personal list, i.e., !isIncoming)
    // AND it must be on the same day it was created.
    bool canEdit = !isIncoming && report.createdAt != null &&
        DateTime.now().year == report.createdAt!.year &&
        DateTime.now().month == report.createdAt!.month &&
        DateTime.now().day == report.createdAt!.day;

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.s16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.buttons).withOpacity(0.06),
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
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(AppColors.buttons).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.calendar_month_rounded, color: Color(AppColors.buttons), size: 20),
                        ),
                        SizedBox(width: 12),
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
                                color: Color(AppColors.secondaryButton),
                              )
                            ),
                            if (displayName != null) ...[
                              SizedBox(height: 2),
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    if (canEdit)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(AppColors.buttons).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit_rounded, color: Color(AppColors.buttons), size: 16)
                            ),
                            onPressed: () {
                              context.pushNamed(
                                AppRoutes.addEditDailyReportScreen.name,
                                pathParameters: {'lang': context.locale.languageCode},
                                extra: report,
                              ).then((_) {
                                if (context.mounted) {
                                  provider.fetchReports(context);
                                  if (provider.isManagerOrHr) provider.fetchReports(context, isIncoming: true);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16)
                            ),
                            onPressed: () => _deleteReport(context, report, provider),
                          ),
                        ],
                      )
                    else
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300)
                  ],
                ),
                if ((isIncoming ? report.employeeProfile?.department : report.done) != null && 
                    (isIncoming ? report.employeeProfile!.department! : report.done!).isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 12),
                    child: Divider(height: 1, color: Colors.grey.shade100),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(isIncoming ? Icons.business_rounded : Icons.check_circle_rounded, 
                           color: isIncoming ? Colors.blue.shade400 : Colors.green.shade400, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isIncoming ? report.employeeProfile!.department! : report.done!, 
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.titleTextContent(context).copyWith(
                            fontWeight: isIncoming ? FontWeight.w500 : FontWeight.w400,
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
  }
}
