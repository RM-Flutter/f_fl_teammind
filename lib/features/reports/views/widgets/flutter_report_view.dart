import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/report_data_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlutterReportView extends StatelessWidget {
  final ReportDataModel reportData;

  const FlutterReportView({Key? key, required this.reportData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryCard(context),
          const SizedBox(height: 20),
          Text(
            'employees_list'.tr(),
            style: AppStyles.blackContent(context).copyWith(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...reportData.employees.map((emp) => _buildEmployeeCard(context, emp)),
        ],
      ),
    );
  }

  /// ─── Summary Card ────────────────────────────────────────────────────────
  Widget _buildSummaryCard(BuildContext context) {
    final s = reportData.summary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period header
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 16, color: Color(AppColors.buttons)),
              const SizedBox(width: 8),
              Text(
                '${reportData.period.from}  →  ${reportData.period.to}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildInfoRow(context, icon: Icons.people_outline, label: 'total_employees'.tr(), value: '${s.totalEmployees}'),
          const SizedBox(height: 8),
          _buildInfoRow(context, icon: Icons.check_circle_outline, label: 'attendance_days'.tr(), value: '${s.totalAttendanceDays}', valueColor: Color(AppColors.successGreen)),
          const SizedBox(height: 8),
          _buildInfoRow(context, icon: Icons.cancel_outlined, label: 'absence_days'.tr(), value: '${s.totalAbsenceDays}', valueColor: Color(AppColors.failureRed)),
          const SizedBox(height: 8),
          if (s.totalDelayReadable.isNotEmpty && s.totalDelayReadable != '0') ...[
            _buildInfoRow(context, icon: Icons.timer_outlined, label: 'total_delay'.tr(), value: s.totalDelayReadable, valueColor: const Color(0xFFE65100)),
            const SizedBox(height: 8),
          ],
          if (s.totalOvertimeReadable.isNotEmpty && s.totalOvertimeReadable != '0')
            _buildInfoRow(context, icon: Icons.more_time_outlined, label: 'total_overtime'.tr(), value: s.totalOvertimeReadable, valueColor: Color(AppColors.buttons)),
        ],
      ),
    );
  }

  /// ─── Employee Card ────────────────────────────────────────────────────────
  Widget _buildEmployeeCard(BuildContext context, ReportEmployeeData emp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          iconColor: Color(AppColors.buttons),
          collapsedIconColor: Colors.grey.shade400,
          leading: GestureDetector(
            onTap: () {
              if (emp.employeeId != 0) {
                context.pushNamed(
                  AppRoutes.employeeDetails.name,
                  pathParameters: {
                    'id': emp.employeeId.toString(),
                    'lang': context.locale.languageCode,
                  },
                );
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(AppColors.buttons).withOpacity(0.1),
                  backgroundImage: emp.avatar.isNotEmpty ? NetworkImage(emp.avatar) : null,
                  child: emp.avatar.isEmpty
                      ? Icon(Icons.person, color: Color(AppColors.buttons), size: 22)
                      : null,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Color(AppColors.buttons),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.open_in_new, color: Colors.white, size: 10),
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            emp.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
          ),
          subtitle: Text(
            emp.departmentName,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  // Stats row
                  Row(
                    children: [
                      _buildStatBadge(context, label: 'attendance'.tr(), value: '${emp.attendanceCount}', color: Color(AppColors.successGreen)),
                      const SizedBox(width: 8),
                      _buildStatBadge(context, label: 'absence'.tr(), value: '${emp.absenceCount}', color: Color(AppColors.failureRed)),
                      const SizedBox(width: 8),
                      if (emp.totalDelayReadable.isNotEmpty && emp.totalDelayReadable != '0')
                        _buildStatBadge(context, label: 'delay'.tr(), value: emp.totalDelayReadable, color: const Color(0xFFE65100)),
                    ],
                  ),
                  // Timeline
                  if (emp.timeline.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('timeline'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 8),
                    ...emp.timeline.map((item) => _buildTimelineRow(context, item)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(BuildContext context, ReportTimeline item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(item.statusLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.delayReadable.isNotEmpty && item.delayReadable != '0')
                _buildTimeBadge(item.delayReadable, const Color(0xFFE65100)),
              if (item.overtimeReadable.isNotEmpty && item.overtimeReadable != '0')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildTimeBadge(item.overtimeReadable, Color(AppColors.buttons)),
                ),
              if (item.checkIn != null && item.checkIn!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${item.checkIn} → ${item.checkOut ?? ''}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStatBadge(BuildContext context, {required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Color(AppColors.buttons)),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87),
          ),
        ),
      ],
    );
  }
}
