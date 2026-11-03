import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/employee_leave_schedule_report_model.dart';
import 'package:app_test/features/reports/views/widgets/report_compare_tabs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class EmployeeLeaveScheduleReportView extends StatefulWidget {
  final EmployeeLeaveScheduleReportModel data;
  final String? currentSubtitle;
  final String? compareSubtitle;

  const EmployeeLeaveScheduleReportView({
    Key? key,
    required this.data,
    this.currentSubtitle,
    this.compareSubtitle,
  }) : super(key: key);

  @override
  State<EmployeeLeaveScheduleReportView> createState() => _EmployeeLeaveScheduleReportViewState();
}

class _EmployeeLeaveScheduleReportViewState extends State<EmployeeLeaveScheduleReportView> {
  int _selectedTabIndex = 0;

  @override
  void didUpdateWidget(covariant EmployeeLeaveScheduleReportView oldWidget) {
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

    // Compute aggregations using activeData
    final totalEvents = activeData.events.length;
    num totalDays = 0;
    final Set<int> uniqueEmpIds = {};
    final Map<String, int> leaveTypeCounts = {};

    for (var ev in activeData.events) {
      totalDays += ev.daysCount;
      if (ev.employeeId > 0) uniqueEmpIds.add(ev.employeeId);
      final type = ev.leaveType.isNotEmpty ? ev.leaveType : 'other'.tr();
      leaveTypeCounts[type] = (leaveTypeCounts[type] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
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
            const SizedBox(height: 16),
          ],
          _buildStatCards(context, totalEvents, totalDays, uniqueEmpIds.length),
          const SizedBox(height: 16),
          _buildLeaveTypesChartCard(context, leaveTypeCounts, totalEvents),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'scheduled_leaves'.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(AppColors.buttons).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  '$totalEvents ${'events'.tr()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.buttons),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activeData.events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('no_data'.tr(), style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...activeData.events.map((ev) => _buildEventCard(context, ev)),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, int totalEvents, num totalDays, int totalEmps) {
    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'total_leaves'.tr(),
          value: totalEvents.toString(),
          icon: Icons.calendar_month_outlined,
          color: Color(AppColors.buttons),
          bgColor: Color(AppColors.buttons).withOpacity(0.08),
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          context,
          title: 'total_days'.tr(),
          value: totalDays.toStringAsFixed(0),
          icon: Icons.date_range_outlined,
          color: const Color(0xFF6366F1),
          bgColor: const Color(0xFF6366F1).withOpacity(0.08),
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          context,
          title: 'employees'.tr(),
          value: (totalEmps > 0 ? totalEmps : totalEvents).toString(),
          icon: Icons.people_outline,
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFF10B981).withOpacity(0.08),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveTypesChartCard(
    BuildContext context,
    Map<String, int> typeCounts,
    int totalEvents,
  ) {
    if (typeCounts.isEmpty) return const SizedBox.shrink();

    final palette = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
    ];

    final entries = typeCounts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 20, color: Color(AppColors.buttons)),
              const SizedBox(width: 8),
              Text(
                'leave_types_distribution'.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 52,
                    startDegreeOffset: -90,
                    sections: List.generate(entries.length, (i) {
                      final count = entries[i].value;
                      final color = palette[i % palette.length];
                      final pct = (count / totalEvents * 100);
                      return PieChartSectionData(
                        value: count.toDouble(),
                        color: color,
                        title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
                        radius: 36,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalEvents.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.buttons),
                      ),
                    ),
                    Text(
                      'total'.tr(),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(entries.length, (i) {
              final label = entries[i].key;
              final count = entries[i].value;
              final color = palette[i % palette.length];
              final pct = (count / totalEvents * 100).toStringAsFixed(1);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$label: $count ($pct%)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, LeaveScheduleEventItem ev) {
    Color parseColor(String hex) {
      try {
        final buffer = StringBuffer();
        if (hex.length == 6 || hex.length == 7) buffer.write('ff');
        buffer.write(hex.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (_) {
        return const Color(0xFF6B7280);
      }
    }

    final color = parseColor(ev.statusColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.12),
                child: Text(
                  ev.employeeName.isNotEmpty ? ev.employeeName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev.employeeName.isNotEmpty ? ev.employeeName : 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (ev.departmentName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ev.departmentName,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  ev.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(AppColors.buttons).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  ev.leaveType,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(AppColors.buttons),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${ev.daysCount} ${'days'.tr()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.date_range_outlined, size: 13, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${ev.startDate} → ${ev.endDate}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
