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
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

class DailyReportsListScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const DailyReportsListScreen({Key? key, this.extra}) : super(key: key);

  @override
  State<DailyReportsListScreen> createState() => _DailyReportsListScreenState();
}

class _DailyReportsListScreenState extends State<DailyReportsListScreen> {
  late DailyReportsProvider provider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = Provider.of<DailyReportsProvider>(context, listen: false);
      if (widget.extra != null) {
        if (widget.extra!['isIncoming'] == true) {
          provider.isForDepartment = true;
          provider.incomingFilters['empId'] = widget.extra!['empId'];
          provider.incomingFilters['empName'] = widget.extra!['empName'];
        } else {
          provider.isForDepartment = false;
        }
      } else {
        provider.isForDepartment = false;
      }
      
      if (provider.isManagerOrHr) {
        provider.fetchReports(context, isIncoming: true);
      }
      provider.fetchReports(context);
      setState(() {});
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (provider.isForDepartment) {
          if (!provider.incomingIsLoadingMore && provider.incomingHasMore) {
            provider.fetchReports(context, isIncoming: true, loadMore: true);
          }
        } else {
          if (!provider.personalIsLoadingMore && provider.personalHasMore) {
            provider.fetchReports(context, isIncoming: false, loadMore: true);
          }
        }
      }
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
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
                              borderRadius: BorderRadius.circular(AppRadius.md),
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
                              borderRadius: BorderRadius.circular(AppRadius.md),
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
                      underMyManagement: true,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
        controller: _scrollController,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: list.length + (provider.isForDepartment ? (provider.incomingIsLoadingMore ? 1 : 0) : (provider.personalIsLoadingMore ? 1 : 0)),
        itemBuilder: (context, index) {
          if (index == list.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = list[index];
          return _buildReportCard(item, provider, isIncoming: isIncoming);
        },
      ),
    );
  }

  Widget _buildReportCard(DailyReportModel report, DailyReportsProvider provider, {required bool isIncoming}) {
    final String? displayName = report.employeeProfile?.name;
    final bool canEdit = !isIncoming &&
        report.createdAt != null &&
        DateTime.now().year == report.createdAt!.year &&
        DateTime.now().month == report.createdAt!.month &&
        DateTime.now().day == report.createdAt!.day;

    final String dateTitle = report.createdAt != null
        ? DateFormat('EEEE, dd MMM yyyy', context.locale.languageCode)
            .format(report.createdAt!)
        : "No Date";

    final String? subLine = isIncoming
        ? [
            if (displayName != null && displayName.isNotEmpty) displayName,
            if (report.employeeProfile?.department != null &&
                report.employeeProfile!.department!.isNotEmpty)
              report.employeeProfile!.department!,
          ].join(' · ')
        : report.done;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: AppSpacing.cardPadding,
      onTap: () {
        context.pushNamed(
          AppRoutes.dailyReportDetailsScreen.name,
          pathParameters: {'lang': context.locale.languageCode},
          extra: report,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCardLeadingAvatar(
            nameForInitials: displayName ?? dateTitle,
            icon: isIncoming ? null : Icons.calendar_month_rounded,
            borderColor: Color(AppColors.buttons),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isIncoming && displayName != null && displayName.isNotEmpty
                      ? displayName
                      : dateTitle,
                  style: AppStyles.heading(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  isIncoming
                      ? [
                          dateTitle,
                          if (report.employeeProfile?.department != null &&
                              report.employeeProfile!.department!.isNotEmpty)
                            report.employeeProfile!.department!,
                        ].join(' · ')
                      : (subLine != null && subLine.isNotEmpty
                          ? subLine
                          : dateTitle),
                  style: AppStyles.subtitleContent(context).copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canEdit)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    context
                        .pushNamed(
                      AppRoutes.addEditDailyReportScreen.name,
                      pathParameters: {'lang': context.locale.languageCode},
                      extra: report,
                    )
                        .then((_) {
                      if (context.mounted) {
                        provider.fetchReports(context);
                        if (provider.isManagerOrHr) {
                          provider.fetchReports(context, isIncoming: true);
                        }
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(AppColors.buttons).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_rounded,
                        color: Color(AppColors.buttons), size: 16),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _deleteReport(context, report, provider),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(AppColors.failureRed).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Color(AppColors.failureRed), size: 16),
                  ),
                ),
              ],
            )
          else
            AppStatusBadge(
              label: 'submitted'.tr(),
              color: Color(AppColors.successGreen),
              icon: Icons.check_circle_outline_rounded,
            ),
        ],
      ),
    );
  }
}
