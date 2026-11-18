import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import 'package:app_test/core/widgets/shared_list_filter_widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import '../../controllers/group_tracking_map_controller.dart';
import '../../data/models/employee_tracking_summary.model.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/repos/tracking_repo.dart';
import '../widgets/tracking_choice_chip.dart';
import '../widgets/tracking_key_points_timeline.dart';
import '../widgets/tracking_map_view_dialog.dart';
import '../widgets/tracking_metrics.dart';
import '../widgets/tracking_route_map.dart';
import '../widgets/tracking_status_badge.dart';

/// Group tracking map (API doc screen 4), from More → "Team Tracking".
///
/// - Live (refreshed every 60 s), Today (live state + today's routes) or a picked day.
/// - 10 employees per page; each one in the palette colour of their `color_index`, the same in
///   live and history for the same page and filters.
/// - Filters: employee, department (filter sheet) and, in Live, "only tracking".
/// - Pick an employee for their status card, distance and hours, key points, and their request's
///   full route.
class LiveGroupMapScreen extends StatelessWidget {
  const LiveGroupMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupTrackingMapController>(
      create: (ctx) => GroupTrackingMapController()..load(ctx),
      child: const _GroupMapView(),
    );
  }
}

class _GroupMapView extends StatelessWidget {
  const _GroupMapView();

  Future<void> _pickDate(BuildContext context, GroupTrackingMapController c) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: c.pickedDate ?? now.subtract(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 180)),
      lastDate: now,
    );
    if (date != null && context.mounted) c.setMode(context, GroupMapMode.date, date: date);
  }

  Future<void> _openFilters(BuildContext context, GroupTrackingMapController c) async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SharedListFilterWidget(
        showEmployee: true,
        showDepartment: true,
        showDateRange: false,
        initialFilters: {'empId': c.employeeId, 'depId': c.departmentId},
        underMyManagement: true,
      ),
    );
    if (result != null && context.mounted) c.applyFilters(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GroupTrackingMapController>();
    final employees = c.employees;
    final selected = c.selected;
    final isLive = c.mode == GroupMapMode.live;

    // Live: one marker per employee at `last_point` (none when null).
    // Today / a picked day: one line per session, in the employee's colour.
    List<TrackingRouteLine> linesOf(EmployeeTrackingSummaryModel e) {
      final color = TrackingPalette.colorAt(e.colorIndex);
      final dimmed = selected != null && selected.employeeId != e.employeeId;
      final label = e.name.split(' ').first;
      if (isLive) {
        if (e.lastPoint == null) return const [];
        return [
          TrackingRouteLine(
              color: color, points: [e.lastPoint!], showLivePosition: true, liveLabel: label, dimmed: dimmed),
        ];
      }
      return [
        for (final s in e.sessions)
          TrackingRouteLine(
            color: color,
            points: s.points,
            showLivePosition: c.mode == GroupMapMode.today && s.isActive,
            liveLabel: label,
            dimmed: dimmed,
          ),
      ];
    }

    final lines = <TrackingRouteLine>[for (final e in employees) ...linesOf(e)];

    final dateLabel = c.pickedDate == null
        ? 'tracking_pick_day'.tr()
        : DateFormat('d MMM', context.locale.languageCode).format(c.pickedDate!);
    final from = employees.isEmpty ? 0 : (c.result.page - 1) * c.result.itemsCount + 1;
    final to = employees.isEmpty ? 0 : from + employees.length - 1;

    return TemplatePage(
      pageContext: context,
      title: 'tracking_team_map'.tr(),
      routeName: AppRoutes.liveGroupMap.name,
      backgroundColor: Color(AppColors.background),
      onRefresh: () => c.load(context, silent: true),
      actions: [
        IconButton(
          tooltip: 'filter'.tr(),
          icon: Badge(
            isLabelVisible: c.hasFilters,
            smallSize: 8,
            child: Icon(Icons.filter_list_rounded, color: Color(AppColors.secondaryButton)),
          ),
          onPressed: () => _openFilters(context, c),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          TrackingChipsRow(chips: [
            TrackingChoiceChip(
              label: 'tracking_live'.tr(),
              icon: Icons.sensors_rounded,
              selected: isLive,
              onTap: () => c.setMode(context, GroupMapMode.live),
            ),
            TrackingChoiceChip(
              label: 'tracking_today'.tr(),
              icon: Icons.today_outlined,
              selected: c.mode == GroupMapMode.today,
              onTap: () => c.setMode(context, GroupMapMode.today),
            ),
            TrackingChoiceChip(
              label: dateLabel,
              icon: Icons.event_outlined,
              selected: c.mode == GroupMapMode.date,
              onTap: () => _pickDate(context, c),
            ),
            if (isLive)
              TrackingChoiceChip(
                label: 'tracking_only_tracking'.tr(),
                icon: Icons.my_location_rounded,
                selected: c.onlyTracking,
                onTap: () => c.toggleOnlyTracking(context),
              ),
          ]),
          if (c.hasFilters) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: AppSpacing.pagePadding,
              child: Text(
                [c.employeeName, c.departmentName].whereType<String>().join(' · '),
                style: AppStyles.greyContent(context).copyWith(fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (employees.isNotEmpty)
            TrackingChipsRow(chips: [
              TrackingChoiceChip(
                label: 'tracking_all_employees'.tr(namedArgs: {'n': '${employees.length}'}),
                selected: selected == null,
                onTap: () => c.select(null),
              ),
              for (final e in employees)
                TrackingChoiceChip(
                  label: e.name,
                  dotColor: TrackingPalette.colorAt(e.colorIndex),
                  selected: e.employeeId == c.selectedEmployeeId,
                  onTap: () => c.select(e.employeeId),
                ),
            ]),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.pagePadding,
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                border: AppBorders.card,
                boxShadow: AppShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TrackingRouteMap(lines: lines, showAutoPoints: selected != null),
                  ),
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: _MapTag(
                      text: isLive
                          ? 'tracking_live_now'.tr()
                          : c.mode == GroupMapMode.today
                              ? 'tracking_history_today'.tr()
                              : 'tracking_history_of'.tr(namedArgs: {'date': dateLabel}),
                      live: isLive,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: AppSpacing.pagePadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'tracking_employees_range'.tr(namedArgs: {
                      'from': '$from',
                      'to': '$to',
                      'total': '${c.result.total}',
                    }),
                    style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                  ),
                ),
                _PageButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: c.page > 1 && !c.isLoading ? () => c.goToPage(context, c.page - 1) : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('${c.page} / ${c.pages}',
                    style: AppStyles.heading(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSpacing.sm),
                _PageButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: c.page < c.pages && !c.isLoading ? () => c.goToPage(context, c.page + 1) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          Padding(
            padding: AppSpacing.pagePadding,
            child: _body(context, c, selected),
          ),
          const SizedBox(height: AppSpacing.listBottom),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, GroupTrackingMapController c, EmployeeTrackingSummaryModel? selected) {
    if (c.isLoading && c.employees.isEmpty) {
      return const AppShimmerList(count: 4, padding: EdgeInsets.zero, showAvatar: true);
    }
    if (c.errorMessage != null && c.employees.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Text(c.errorMessage!, textAlign: TextAlign.center, style: AppStyles.greyContent(context)),
            TextButton(onPressed: () => c.load(context), child: Text('retry'.tr())),
          ],
        ),
      );
    }
    if (c.employees.isEmpty) {
      return AppCard(
        child: Text('tracking_no_employees'.tr(),
            textAlign: TextAlign.center, style: AppStyles.greyContent(context).copyWith(fontSize: 12.5)),
      );
    }
    if (selected != null) {
      return _EmployeeStatusCard(employee: selected, mode: c.mode);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: 'tracking_employees'.tr()),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        for (var i = 0; i < c.employees.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.cardGap),
          _EmployeeRow(
            employee: c.employees[i],
            mode: c.mode,
            onTap: () => c.select(c.employees[i].employeeId),
          ),
        ],
      ],
    );
  }
}

/// Opens the full route of the employee's request (`GET /requests/{request_id}/path`).
Future<void> _openRequestRoute(BuildContext context, EmployeeTrackingSummaryModel e) async {
  final requestId = e.requestId;
  if (requestId == null) return;
  final details = await TrackingRepo.getRequestTracking(context: context, requestId: requestId);
  if (!context.mounted) return;
  final mainPoints = <TrackingPointModel>[
    for (final s in details.data?.sessions ?? const []) ...s.points,
  ];
  final path = await TrackingRepo.getPath(context: context, requestId: requestId, mainPoints: mainPoints);
  if (!context.mounted) return;
  if (!path.success || path.data == null) {
    AlertsService.error(context: context, title: 'tracking', message: path.message ?? 'something_went_wrong');
    return;
  }
  TrackingMapViewDialog.show(context, title: 'full_request_route_map'.tr(), sessions: path.data!);
}

/// "Live now" / "History · 12 Nov" tag in the corner of the map.
class _MapTag extends StatelessWidget {
  final String text;
  final bool live;
  const _MapTag({required this.text, required this.live});

  @override
  Widget build(BuildContext context) {
    final color = live ? Color(AppColors.successGreen) : Color(AppColors.secondaryButton);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s10, vertical: AppSizes.s5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppSizes.s6),
          Text(text,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.statusTones(color).text)),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      shape: CircleBorder(side: BorderSide(color: AppField.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          // Flutter mirrors chevrons by itself in RTL.
          child: Icon(icon, size: 20, color: enabled ? Color(AppColors.secondaryButton) : AppField.borderColor),
        ),
      ),
    );
  }
}

String _subtitle(EmployeeTrackingSummaryModel e) =>
    [e.jobTitle, e.departmentName].whereType<String>().where((s) => s.isNotEmpty).join(' · ');

/// One employee in the list: colour ring, name, job and department, presence and last update.
class _EmployeeRow extends StatelessWidget {
  final EmployeeTrackingSummaryModel employee;
  final GroupMapMode mode;
  final VoidCallback onTap;
  const _EmployeeRow({required this.employee, required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard.listItem(
      context: context,
      title: employee.name,
      subtitle: _subtitle(employee),
      thirdLine: mode == GroupMapMode.date ? null : employee.getLastUpdatedText(),
      avatarInitialsText: employee.name,
      accentColor: TrackingPalette.colorAt(employee.colorIndex),
      trailing: EmployeePresenceBadge(presence: employee.presence),
      onTap: onTap,
    );
  }
}

/// The picked employee: presence, last update, current session, distance and hours, their key
/// points in time order and their request's full route.
class _EmployeeStatusCard extends StatelessWidget {
  final EmployeeTrackingSummaryModel employee;
  final GroupMapMode mode;
  const _EmployeeStatusCard({required this.employee, required this.mode});

  @override
  Widget build(BuildContext context) {
    final color = TrackingPalette.colorAt(employee.colorIndex);
    final active = employee.activeSession;
    final sessions = employee.sessions;
    final hasHistory = mode != GroupMapMode.live;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppCardLeadingAvatar(nameForInitials: employee.name, borderColor: color),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSizes.s2),
                        Text(_subtitle(employee),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  EmployeePresenceBadge(presence: employee.presence),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: Color(AppColors.divider)),
              const SizedBox(height: AppSpacing.md),
              if (mode != GroupMapMode.date) ...[
                _InfoLine(
                  icon: Icons.update_rounded,
                  label: 'tracking_last_update'.tr(),
                  value: employee.getLastUpdatedText(),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (hasHistory) ...[
                _InfoLine(
                  icon: Icons.timer_outlined,
                  label: 'tracking_current_leg'.tr(),
                  value: active != null ? active.getDurationFormatted() : '—',
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoLine(
                  icon: Icons.repeat_rounded,
                  label: 'tracking_start_stop_count'.tr(),
                  value: '${sessions.length}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoLine(
                  icon: Icons.route_outlined,
                  label: 'tracking_distance'.tr(),
                  value: 'tracking_km'.tr(namedArgs: {'km': (employee.totalDistanceMeters / 1000).toStringAsFixed(1)}),
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoLine(
                  icon: Icons.schedule_rounded,
                  label: 'active_hours'.tr(),
                  value: TrackingMetricsRow.formatHours(employee.totalActiveSeconds / 3600),
                ),
              ],
              if (employee.requestId != null) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: AppButtonSize.height,
                  child: OutlinedButton.icon(
                    onPressed: () => _openRequestRoute(context, employee),
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: Text('view_full_route_on_map'.tr(),
                        style: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppColors.secondaryButton),
                      side: BorderSide(color: Color(AppColors.secondaryButton)),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasHistory) ...[
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(title: 'tracking_key_points'.tr()),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          TrackingKeyPointsTimeline(sessions: sessions, accent: color, showLeg: sessions.length > 1),
        ],
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppField.iconColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label, style: AppStyles.greyContent(context).copyWith(fontSize: 12.5))),
        Text(value, style: AppStyles.heading(context).copyWith(fontSize: 12.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
