import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/annual_leave_entitlement_report_model.dart';
import 'package:app_test/features/reports/views/widgets/report_compare_tabs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class AnnualLeaveEntitlementReportView extends StatefulWidget {
  final AnnualLeaveEntitlementReportModel data;
  final String? currentSubtitle;
  final String? compareSubtitle;

  const AnnualLeaveEntitlementReportView({
    Key? key,
    required this.data,
    this.currentSubtitle,
    this.compareSubtitle,
  }) : super(key: key);

  @override
  State<AnnualLeaveEntitlementReportView> createState() => _AnnualLeaveEntitlementReportViewState();
}

class _AnnualLeaveEntitlementReportViewState extends State<AnnualLeaveEntitlementReportView> {
  int _selectedTabIndex = 0;

  @override
  void didUpdateWidget(covariant AnnualLeaveEntitlementReportView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.compare == null) {
      _selectedTabIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCompare = widget.data.compare != null;
    final activeData = (hasCompare && _selectedTabIndex == 1)
        ? widget.data.compare!
        : widget.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSizes.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasCompare) ...[
            ReportCompareTabs(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (idx) => setState(() => _selectedTabIndex = idx),
              currentSubtitle: widget.currentSubtitle,
              compareSubtitle: widget.compareSubtitle,
            ),
            const SizedBox(height: AppSizes.s16),
          ],
          _buildSummaryCards(context, activeData),
          const SizedBox(height: AppSizes.s16),
          _buildUsageDonutChartCard(context, activeData),
          const SizedBox(height: AppSizes.s20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'employees_list'.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: Color(AppColors.buttons).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  '${activeData.employees.length} ${'employees'.tr()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.buttons),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          if (activeData.employees.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s32),
                child: Text('no_data'.tr(), style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...activeData.employees.map((emp) => _buildEmployeeCard(context, emp)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, AnnualLeaveEntitlementReportModel currentData) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              context,
              title: 'total_employees'.tr(),
              value: currentData.totalEmployees.toString(),
              icon: Icons.people_outline,
              color: Color(AppColors.buttons),
              bgColor: Color(AppColors.buttons).withOpacity(0.08),
            ),
            const SizedBox(width: AppSizes.s12),
            _buildStatCard(
              context,
              title: 'total_entitlement'.tr(),
              value: '${currentData.totalEntitlementDays.toStringAsFixed(0)} ${'days'.tr()}',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF6366F1),
              bgColor: const Color(0xFF6366F1).withOpacity(0.08),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s12),
        Row(
          children: [
            _buildStatCard(
              context,
              title: 'taken_days'.tr(),
              value: '${currentData.totalTakenDays.toStringAsFixed(0)} ${'days'.tr()}',
              icon: Icons.flight_takeoff_outlined,
              color: const Color(0xFFF59E0B),
              bgColor: const Color(0xFFF59E0B).withOpacity(0.08),
            ),
            const SizedBox(width: AppSizes.s12),
            _buildStatCard(
              context,
              title: 'remaining_days'.tr(),
              value: '${currentData.totalRemainingDays.toStringAsFixed(0)} ${'days'.tr()}',
              icon: Icons.savings_outlined,
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFF10B981).withOpacity(0.08),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.s14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.s10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSizes.s4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageDonutChartCard(BuildContext context, AnnualLeaveEntitlementReportModel currentData) {
    final taken = currentData.totalTakenDays.toDouble();
    final remaining = currentData.totalRemainingDays.toDouble();
    final total = taken + remaining;
    final usageRate = currentData.overallUsageRate;

    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart_outline, size: 20, color: Color(AppColors.buttons)),
                  const SizedBox(width: AppSizes.s8),
                  Text(
                    'overall_usage'.tr(),
                    style: AppStyles.blackContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${'usage_rate'.tr()}: ${usageRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s18),
          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s24),
                child: Text('no_data'.tr(), style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else ...[
            SizedBox(
              height: AppSizes.s180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 52,
                      startDegreeOffset: -90,
                      sections: [
                        if (taken > 0)
                          PieChartSectionData(
                            value: taken,
                            color: const Color(0xFFF59E0B),
                            title: '${((taken / total) * 100).toStringAsFixed(0)}%',
                            radius: 36,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (remaining > 0)
                          PieChartSectionData(
                            value: remaining,
                            color: const Color(0xFF10B981),
                            title: '${((remaining / total) * 100).toStringAsFixed(0)}%',
                            radius: 36,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${usageRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.buttons),
                        ),
                      ),
                      Text(
                        'usage_rate'.tr(),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.s16),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('taken_days'.tr(), taken.toInt(), total.toInt(), const Color(0xFFF59E0B)),
                _buildLegendItem('remaining_days'.tr(), remaining.toInt(), total.toInt(), const Color(0xFF10B981)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.s6),
        Text(
          '$label: $count ${'days'.tr()} ($pct%)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(BuildContext context, AnnualLeaveEmployeeItem emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      padding: const EdgeInsets.all(AppSizes.s14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(AppColors.buttons).withOpacity(0.1),
                child: Text(
                  emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.buttons),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name.isNotEmpty ? emp.name : 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppSizes.s2),
                    Text(
                      [
                        if (emp.jobTitle.isNotEmpty) emp.jobTitle,
                        if (emp.departmentName.isNotEmpty) emp.departmentName,
                      ].join(' • '),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s3),
                decoration: BoxDecoration(
                  color: emp.isQualified
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  emp.isQualified ? 'qualified'.tr() : 'not_qualified'.tr(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: emp.isQualified ? const Color(0xFF10B981) : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s14),
          Row(
            children: [
              _buildMiniStat(
                context,
                label: 'entitlement'.tr(),
                value: '${emp.entitlementDays.toStringAsFixed(0)} ${'days'.tr()}',
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: AppSizes.s8),
              _buildMiniStat(
                context,
                label: 'taken'.tr(),
                value: '${emp.takenDays.toStringAsFixed(0)} ${'days'.tr()}',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: AppSizes.s8),
              _buildMiniStat(
                context,
                label: 'remaining'.tr(),
                value: '${emp.remainingDays.toStringAsFixed(0)} ${'days'.tr()}',
                color: const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'usage_rate'.tr(),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    '${emp.usagePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: emp.usagePercentage > 80
                          ? const Color(0xFFEF4444)
                          : Color(AppColors.buttons),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.s4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: LinearProgressIndicator(
                  value: (emp.usagePercentage / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    emp.usagePercentage > 80
                        ? const Color(0xFFEF4444)
                        : Color(AppColors.buttons),
                  ),
                ),
              ),
            ],
          ),
          if (emp.hireDate.isNotEmpty || emp.notes.isNotEmpty) ...[
            const SizedBox(height: AppSizes.s10),
            Row(
              children: [
                if (emp.hireDate.isNotEmpty) ...[
                  Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: AppSizes.s4),
                  Text(
                    '${'hire_date'.tr()}: ${emp.hireDate}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
                if (emp.notes.isNotEmpty) ...[
                  const Spacer(),
                  Text(
                    emp.notes,
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, {required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s6, horizontal: AppSizes.s4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: AppSizes.s2),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
