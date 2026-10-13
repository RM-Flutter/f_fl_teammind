import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/reports/data/models/requests_summary_report_model.dart';
import 'package:app_test/features/reports/views/widgets/report_compare_tabs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RequestsSummaryReportView extends StatefulWidget {
  final RequestsSummaryReportModel data;
  final String? currentSubtitle;
  final String? compareSubtitle;

  const RequestsSummaryReportView({
    Key? key,
    required this.data,
    this.currentSubtitle,
    this.compareSubtitle,
  }) : super(key: key);

  @override
  State<RequestsSummaryReportView> createState() => _RequestsSummaryReportViewState();
}

class _RequestsSummaryReportViewState extends State<RequestsSummaryReportView> {
  int _selectedTabIndex = 0;

  @override
  void didUpdateWidget(covariant RequestsSummaryReportView oldWidget) {
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
          _buildStatCards(context, activeData),
          const SizedBox(height: 16),
          _buildStatusDonutChartCard(context, activeData),
          const SizedBox(height: 16),
          _buildTypeBreakdownCard(context, activeData),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, RequestsSummaryReportModel currentData) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCard(
              context,
              title: 'total_requests'.tr(),
              value: currentData.totalCount.toString(),
              icon: Icons.receipt_long_outlined,
              color: Color(AppColors.buttons),
              bgColor: Color(AppColors.buttons).withOpacity(0.08),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              context,
              title: 'approved'.tr(),
              value: currentData.approved.toString(),
              icon: Icons.check_circle_outline,
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFF10B981).withOpacity(0.08),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              context,
              title: 'waiting'.tr(),
              value: currentData.pending.toString(),
              icon: Icons.schedule_outlined,
              color: const Color(0xFFF59E0B),
              bgColor: const Color(0xFFF59E0B).withOpacity(0.08),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              context,
              title: 'rejected'.tr(),
              value: currentData.rejected.toString(),
              icon: Icons.cancel_outlined,
              color: const Color(0xFFEF4444),
              bgColor: const Color(0xFFEF4444).withOpacity(0.08),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
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

  Widget _buildStatusDonutChartCard(BuildContext context, RequestsSummaryReportModel currentData) {
    final total = currentData.totalCount;
    final approved = currentData.approved;
    final pending = currentData.pending;
    final rejected = currentData.rejected;

    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                'status_distribution'.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('no_data'.tr(), style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else ...[
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
                      sections: [
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
                        if (pending > 0)
                          PieChartSectionData(
                            value: pending.toDouble(),
                            color: const Color(0xFFF59E0B),
                            title: '${((pending / total) * 100).toStringAsFixed(0)}%',
                            radius: 36,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (rejected > 0)
                          PieChartSectionData(
                            value: rejected.toDouble(),
                            color: const Color(0xFFEF4444),
                            title: '${((rejected / total) * 100).toStringAsFixed(0)}%',
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
                        'requests'.tr(),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem('approved'.tr(), approved, total, const Color(0xFF10B981)),
                _buildLegendItem('waiting'.tr(), pending, total, const Color(0xFFF59E0B)),
                _buildLegendItem('rejected'.tr(), rejected, total, const Color(0xFFEF4444)),
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
        const SizedBox(width: 6),
        Text(
          '$label: $count ($pct%)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTypeBreakdownCard(BuildContext context, RequestsSummaryReportModel currentData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.bar_chart_outlined, size: 20, color: Color(AppColors.buttons)),
              const SizedBox(width: 8),
              Text(
                'requests_by_type'.tr(),
                style: AppStyles.blackContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (currentData.typeBreakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('no_data'.tr(), style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...currentData.typeBreakdown.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.typeName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${item.count} (${item.percentage.toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.buttons),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (item.percentage / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
