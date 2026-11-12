import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/leave_requests_report_model.dart';
import 'package:app_test/features/reports/views/widgets/report_compare_tabs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

class LeaveRequestsReportView extends StatefulWidget {
  final LeaveRequestsReportModel data;
  final String? currentSubtitle;
  final String? compareSubtitle;

  const LeaveRequestsReportView({
    Key? key,
    required this.data,
    this.currentSubtitle,
    this.compareSubtitle,
  }) : super(key: key);

  @override
  State<LeaveRequestsReportView> createState() => _LeaveRequestsReportViewState();
}

class _LeaveRequestsReportViewState extends State<LeaveRequestsReportView> {
  int _selectedTabIndex = 0;

  @override
  void didUpdateWidget(covariant LeaveRequestsReportView oldWidget) {
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
          _buildStatCards(context, activeData),
          const SizedBox(height: AppSizes.s16),
          _buildStatusDonutChartCard(context, activeData),
          const SizedBox(height: AppSizes.s20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'leave_requests'.tr(),
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
                  '${activeData.requests.length} ${'requests'.tr()}',
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
          if (activeData.requests.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s32),
                child: Text('no_data'.tr(), style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...activeData.requests.map((req) => _buildRequestCard(context, req)),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, LeaveRequestsReportModel currentData) {
    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'total'.tr(),
          value: currentData.total.toString(),
          icon: Icons.event_note_outlined,
          color: Color(AppColors.buttons),
          bgColor: Color(AppColors.buttons).withOpacity(0.08),
        ),
        const SizedBox(width: AppSizes.s10),
        _buildStatCard(
          context,
          title: 'waiting'.tr(),
          value: currentData.waitingCount.toString(),
          icon: Icons.hourglass_empty_outlined,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFF59E0B).withOpacity(0.08),
        ),
        const SizedBox(width: AppSizes.s10),
        _buildStatCard(
          context,
          title: 'approved'.tr(),
          value: currentData.approvedCount.toString(),
          icon: Icons.check_circle_outline,
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
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s12, horizontal: AppSizes.s10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.s8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSizes.s8),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSizes.s2),
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

  Widget _buildStatusDonutChartCard(BuildContext context, LeaveRequestsReportModel currentData) {
    final total = currentData.total;
    final waiting = currentData.waitingCount;
    final approved = currentData.approvedCount;
    final refused = currentData.refusedCount;

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
            children: [
              Icon(Icons.donut_large_outlined, size: 20, color: Color(AppColors.buttons)),
              const SizedBox(width: AppSizes.s8),
              Text(
                'status_distribution'.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
                        if (waiting > 0)
                          PieChartSectionData(
                            value: waiting.toDouble(),
                            color: const Color(0xFFF59E0B),
                            title: '${((waiting / total) * 100).toStringAsFixed(0)}%',
                            radius: 36,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (approved > 0)
                          PieChartSectionData(
                            value: approved.toDouble(),
                            color: const Color(0xFF10B981),
                            title: '${((approved / total) * 100).toStringAsFixed(0)}%',
                            radius: 36,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (refused > 0)
                          PieChartSectionData(
                            value: refused.toDouble(),
                            color: const Color(0xFFEF4444),
                            title: '${((refused / total) * 100).toStringAsFixed(0)}%',
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
                        total.toString(),
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
            const SizedBox(height: AppSizes.s16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('waiting'.tr(), waiting, total, const Color(0xFFF59E0B)),
                _buildLegendItem('approved'.tr(), approved, total, const Color(0xFF10B981)),
                if (refused > 0)
                  _buildLegendItem('rejected'.tr(), refused, total, const Color(0xFFEF4444)),
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
          '$label: $count ($pct%)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, LeaveRequestReportItem req) {
    final isWaiting = req.status.toLowerCase().contains('wait') || req.status.toLowerCase().contains('pend');
    final isApproved = req.status.toLowerCase().contains('approv');
    final statusColor = isApproved
        ? const Color(0xFF10B981)
        : isWaiting
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    final statusText = isWaiting
        ? 'waiting'.tr()
        : (req.statusLabel.isNotEmpty ? req.statusLabel : req.status);

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
                radius: 18,
                backgroundColor: Color(AppColors.buttons).withOpacity(0.1),
                child: Icon(Icons.person_outline, size: 20, color: Color(AppColors.buttons)),
              ),
              const SizedBox(width: AppSizes.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.employeeName.isNotEmpty ? req.employeeName : 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (req.departmentName.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.s2),
                      Text(
                        req.departmentName,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s12),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: AppSizes.s10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s3),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_outlined, size: 13, color: Colors.blueGrey.shade700),
                    const SizedBox(width: AppSizes.s4),
                    Text(
                      req.requestType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey.shade600),
              const SizedBox(width: AppSizes.s4),
              Text(
                '${req.startDate.split(' ').first} → ${req.endDate.split(' ').first}',
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
