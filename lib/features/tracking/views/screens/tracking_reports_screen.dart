import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/routing/app_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:app_test/core/widgets/app_filter_actions.widget.dart';
import 'package:app_test/core/widgets/app_responsive_grid.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/text_form_widget.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_report_row.model.dart';
import '../../data/models/tracking_status.enum.dart';
import '../widgets/tracking_choice_chip.dart';
import '../widgets/tracking_map_view_dialog.dart';
import '../widgets/tracking_metrics.dart';
import '../widgets/tracking_status_badge.dart';

/// The three tracking reports of the spec (back end §9), inside the app:
/// - Manager compliance: employee, request, required / started / completed, last update.
/// - HR compliance: employee, department, status, start / end, requests not started yet.
/// - Tracking history: date, legs, duration, points, distance and a link to the map.
/// Filters: date, employee, department, request type and tracking status.
/// The reports only help follow up; they never decide a penalty.
///
/// UI only: all data is dummy ([TrackingDummyData]).
class TrackingReportsScreen extends StatefulWidget {
  const TrackingReportsScreen({super.key});

  @override
  State<TrackingReportsScreen> createState() => _TrackingReportsScreenState();
}

enum _Report { manager, hr, history }

class _Filters {
  DateTimeRange? range;
  String? employee;
  String? department;
  String? requestType;
  RequestTrackingStatus? status;

  bool get isEmpty =>
      range == null && employee == null && department == null && requestType == null && status == null;
}

class _TrackingReportsScreenState extends State<TrackingReportsScreen> {
  _Report _report = _Report.manager;
  final _Filters _filters = _Filters();

  List<TrackingReportRowModel> _rows(bool isAr) {
    return TrackingDummyData.reportRows(isAr).where((r) {
      final f = _filters;
      if (f.employee != null && r.employeeName != f.employee) return false;
      if (f.department != null && r.departmentName != f.department) return false;
      if (f.requestType != null && r.requestType != f.requestType) return false;
      if (f.status != null && r.status != f.status) return false;
      if (f.range != null) {
        final d = DateUtils.dateOnly(r.requestDate);
        if (d.isBefore(f.range!.start) || d.isAfter(f.range!.end)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _openFilters() async {
    final isAr = context.locale.languageCode == 'ar';
    final all = TrackingDummyData.reportRows(isAr);
    List<DropdownMenuItem<String>> items(Iterable<String> values) => [
          for (final v in values.toSet()) DropdownMenuItem(value: v, child: Text(v, style: AppField.valueStyle)),
        ];
    final temp = _Filters()
      ..range = _filters.range
      ..employee = _filters.employee
      ..department = _filters.department
      ..requestType = _filters.requestType
      ..status = _filters.status;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final fmt = DateFormat('d MMM', context.locale.languageCode);
          return AppFilterSheetFrame(
            title: 'filter'.tr(),
            onApply: () {
              setState(() {
                _filters
                  ..range = temp.range
                  ..employee = temp.employee
                  ..department = temp.department
                  ..requestType = temp.requestType
                  ..status = temp.status;
              });
              Navigator.pop(ctx);
            },
            onClear: () {
              setState(() {
                _filters
                  ..range = null
                  ..employee = null
                  ..department = null
                  ..requestType = null
                  ..status = null;
              });
              Navigator.pop(ctx);
            },
            children: [
              AppFieldShell(
                trailingIcon: Icons.calendar_today_outlined,
                onTap: () async {
                  final now = DateTime.now();
                  final range = await showDateRangePicker(
                    context: ctx,
                    firstDate: now.subtract(const Duration(days: 180)),
                    lastDate: now,
                    initialDateRange: temp.range,
                  );
                  if (range != null) setSheet(() => temp.range = range);
                },
                child: Text(
                  temp.range == null
                      ? 'tracking_filter_date'.tr()
                      : '${fmt.format(temp.range!.start)} – ${fmt.format(temp.range!.end)}',
                  style: temp.range == null ? AppField.hintStyle : AppField.valueStyle,
                ),
              ),
              defaultDropdownField(
                title: 'employee'.tr(),
                value: temp.employee,
                items: items(all.map((r) => r.employeeName)),
                onChanged: (v) => setSheet(() => temp.employee = v),
              ),
              defaultDropdownField(
                title: 'department'.tr(),
                value: temp.department,
                items: items(all.map((r) => r.departmentName)),
                onChanged: (v) => setSheet(() => temp.department = v),
              ),
              defaultDropdownField(
                title: 'request_type'.tr(),
                value: temp.requestType,
                items: items(all.map((r) => r.requestType)),
                onChanged: (v) => setSheet(() => temp.requestType = v),
              ),
              defaultDropdownField(
                title: 'tracking_status'.tr(),
                value: temp.status?.name,
                items: [
                  for (final s in RequestTrackingStatus.values)
                    if (s != RequestTrackingStatus.notRequired)
                      DropdownMenuItem(value: s.name, child: Text(s.getLabel(), style: AppField.valueStyle)),
                ],
                onChanged: (v) => setSheet(
                    () => temp.status = RequestTrackingStatus.values.where((s) => s.name == v).firstOrNull),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final rows = _rows(isAr);
    final required = rows.where((r) => r.isRequired).length;
    final started = rows.where((r) => r.isStarted).length;
    final completed = rows.where((r) => r.isCompleted).length;
    final missing = rows.where((r) => r.isMissing).length;

    return TemplatePage(
      pageContext: context,
      title: 'tracking_reports'.tr(),
      routeName: AppRoutes.trackingReports.name,
      backgroundColor: Color(AppColors.background),
      onRefresh: () async => setState(() {}),
      actions: [
        IconButton(
          tooltip: 'filter'.tr(),
          onPressed: _openFilters,
          icon: Badge(
            isLabelVisible: !_filters.isEmpty,
            smallSize: 8,
            backgroundColor: Color(AppColors.buttons),
            child: Icon(Icons.filter_list_rounded, color: Color(AppColors.secondaryButton)),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          TrackingChipsRow(chips: [
            TrackingChoiceChip(
              label: 'tracking_report_manager'.tr(),
              selected: _report == _Report.manager,
              onTap: () => setState(() => _report = _Report.manager),
            ),
            TrackingChoiceChip(
              label: 'tracking_report_hr'.tr(),
              selected: _report == _Report.hr,
              onTap: () => setState(() => _report = _Report.hr),
            ),
            TrackingChoiceChip(
              label: 'tracking_report_history'.tr(),
              selected: _report == _Report.history,
              onTap: () => setState(() => _report = _Report.history),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppResponsiveGrid(
                  compact: 2,
                  medium: 4,
                  expanded: 4,
                  children: [
                    TrackingMetricTile(
                        icon: Icons.assignment_outlined,
                        value: '$required',
                        label: 'tracking_kpi_required'.tr(),
                        color: Color(AppColors.secondaryButton)),
                    TrackingMetricTile(
                        icon: Icons.play_circle_outline_rounded,
                        value: '$started',
                        label: 'tracking_kpi_started'.tr(),
                        color: Color(AppColors.buttons)),
                    TrackingMetricTile(
                        icon: Icons.check_circle_outline_rounded,
                        value: '$completed',
                        label: 'tracking_kpi_completed'.tr(),
                        color: Color(AppColors.successGreen)),
                    TrackingMetricTile(
                        icon: Icons.error_outline_rounded,
                        value: '$missing',
                        label: 'tracking_kpi_missing'.tr(),
                        color: Color(AppColors.failureRed)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppField.iconColor),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('tracking_report_note'.tr(),
                          style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.section),
                if (rows.isEmpty)
                  NoExistingPlaceholderScreen(title: 'noDataFounded'.tr(), compact: true)
                else
                  AppResponsiveGrid(
                    children: [
                      for (final r in rows)
                        switch (_report) {
                          _Report.manager => _ManagerRow(row: r),
                          _Report.hr => _HrRow(row: r),
                          _Report.history => _HistoryRow(row: r),
                        },
                    ],
                  ),
                const SizedBox(height: AppSpacing.listBottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar, name and the request line shared by the three report rows.
class _RowHeader extends StatelessWidget {
  final TrackingReportRowModel row;
  final String subtitle;
  const _RowHeader({required this.row, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppCardLeadingAvatar(nameForInitials: row.employeeName, borderColor: row.status.baseColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.employeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.s2),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TrackingStatusBadge(status: row.status),
      ],
    );
  }
}

/// A yes / no check: "Required ✓", "Started ✗".
class _Check extends StatelessWidget {
  final String label;
  final bool? value; // null = not applicable
  const _Check({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value == null
        ? const Color(0xFF8A8FA3)
        : value!
            ? Color(AppColors.successGreen)
            : Color(AppColors.failureRed);
    final tones = AppColors.statusTones(color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          value == null
              ? Icons.remove_circle_outline_rounded
              : value!
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
          size: 16,
          color: tones.text,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
      ],
    );
  }
}

class _ManagerRow extends StatelessWidget {
  final TrackingReportRowModel row;
  const _ManagerRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final time = row.lastUpdateAt == null
        ? '—'
        : DateFormat('d MMM · hh:mm a', context.locale.languageCode).format(row.lastUpdateAt!);
    return AppCard(
      animateIn: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RowHeader(row: row, subtitle: '${row.requestType} #${row.requestId}'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _Check(label: 'tracking_kpi_required'.tr(), value: row.isRequired),
              _Check(label: 'tracking_kpi_started'.tr(), value: row.isStarted),
              _Check(label: 'tracking_kpi_completed'.tr(), value: row.isStarted ? row.isCompleted : null),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('tracking_last_update_at'.tr(namedArgs: {'time': time}),
              style: AppStyles.greyContent(context).copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _HrRow extends StatelessWidget {
  final TrackingReportRowModel row;
  const _HrRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('hh:mm a', context.locale.languageCode);
    return AppCard(
      animateIn: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RowHeader(row: row, subtitle: row.departmentName),
          const SizedBox(height: AppSpacing.md),
          if (!row.isStarted)
            Row(
              children: [
                Icon(Icons.hourglass_empty_rounded, size: 16, color: AppColors.statusTones(row.status.baseColor).text),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text('tracking_not_started_yet'.tr(namedArgs: {'request': '${row.requestType} #${row.requestId}'}),
                      style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _KeyValue(label: 'tracking_started_at'.tr(), value: fmt.format(row.startedAt!))),
                Expanded(
                  child: _KeyValue(
                      label: 'tracking_ended_at'.tr(),
                      value: row.endedAt == null ? 'tracking_now'.tr() : fmt.format(row.endedAt!)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final TrackingReportRowModel row;
  const _HistoryRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE d MMM', context.locale.languageCode).format(row.requestDate);
    final employee = [...TrackingDummyData.employeesPage(1), ...TrackingDummyData.employeesPage(2)]
        .where((e) => e.employeeId == row.employeeId)
        .firstOrNull;
    return AppCard(
      animateIn: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RowHeader(row: row, subtitle: date),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _KeyValue(label: 'tracking_legs'.tr(), value: '${row.sessionsCount}')),
              Expanded(
                  child: _KeyValue(
                      label: 'tracking_duration'.tr(),
                      value: TrackingMetricsRow.formatHours(row.durationMinutes / 60))),
              Expanded(child: _KeyValue(label: 'tracking_points'.tr(), value: '${row.pointsCount}')),
              Expanded(
                  child: _KeyValue(
                      label: 'tracking_distance'.tr(),
                      value: 'tracking_km'.tr(namedArgs: {'km': row.distanceKm.toStringAsFixed(1)}))),
            ],
          ),
          if (row.isStarted && employee != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () => TrackingMapViewDialog.show(
                  context,
                  title: row.employeeName,
                  sessions: TrackingDummyData.routeFor(employee, row.employeeId),
                ),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text('tracking_view_on_map'.tr(),
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                style: TextButton.styleFrom(foregroundColor: Color(AppColors.buttons)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.greyContent(context).copyWith(fontSize: 11)),
        const SizedBox(height: AppSizes.s2),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.heading(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
