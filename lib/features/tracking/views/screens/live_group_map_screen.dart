import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_test/core/routing/app_router.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/employee_tracking_summary.model.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import '../widgets/tracking_choice_chip.dart';
import '../widgets/tracking_key_points_timeline.dart';
import '../widgets/tracking_route_map.dart';
import '../widgets/tracking_status_badge.dart';

/// Time range shown on the group map (spec: Live / Today (history) / a picked day).
enum _MapMode { live, today, date }

/// Team tracking map for managers / HR (spec: mobile screen 4).
///
/// - Live, Today or a picked day.
/// - Up to 10 employees per page, each in the colour of their position on the page
///   ([TrackingPalette]); their routes are drawn in the same colour.
/// - Pick one employee to see their status card (Active / Stopped / Offline / No active tracking,
///   last update) and their key points; the others are faded on the map.
///
/// UI only: all data is dummy ([TrackingDummyData]).
class LiveGroupMapScreen extends StatefulWidget {
  const LiveGroupMapScreen({super.key});

  @override
  State<LiveGroupMapScreen> createState() => _LiveGroupMapScreenState();
}

class _LiveGroupMapScreenState extends State<LiveGroupMapScreen> {
  _MapMode _mode = _MapMode.live;
  DateTime? _pickedDate;
  int _page = 1;
  int? _selectedEmployeeId;

  List<EmployeeTrackingSummaryModel> get _employees => TrackingDummyData.employeesPage(_page);

  int get _pages => (TrackingDummyData.totalEmployees / TrackingDummyData.pageSize).ceil();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? now.subtract(const Duration(days: 1)),
      firstDate: now.subtract(const Duration(days: 180)), // points are kept for 6 months
      lastDate: now,
    );
    if (date != null) {
      setState(() {
        _pickedDate = date;
        _mode = _MapMode.date;
      });
    }
  }

  void _goToPage(int page) => setState(() {
        _page = page;
        _selectedEmployeeId = null;
      });

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final employees = _employees;
    final routes = <int, List<TrackingSessionModel>>{
      for (var i = 0; i < employees.length; i++) employees[i].employeeId: TrackingDummyData.routeFor(employees[i], i),
    };
    final selectedIndex = employees.indexWhere((e) => e.employeeId == _selectedEmployeeId);
    final selected = selectedIndex == -1 ? null : employees[selectedIndex];

    final lines = <TrackingRouteLine>[
      for (var i = 0; i < employees.length; i++)
        for (final s in routes[employees[i].employeeId]!)
          TrackingRouteLine(
            color: TrackingPalette.colorAt(i),
            points: s.points,
            showLivePosition: _mode == _MapMode.live && employees[i].status == 'active' && s.isActive,
            liveLabel: employees[i].getName(isArabic: isAr).split(' ').first,
            dimmed: selected != null && selected.employeeId != employees[i].employeeId,
          ),
    ];

    final dateLabel = _pickedDate == null
        ? 'tracking_pick_day'.tr()
        : DateFormat('d MMM', context.locale.languageCode).format(_pickedDate!);
    final from = (_page - 1) * TrackingDummyData.pageSize + 1;
    final to = from + employees.length - 1;

    return TemplatePage(
      pageContext: context,
      title: 'tracking_team_map'.tr(),
      routeName: AppRoutes.liveGroupMap.name,
      backgroundColor: Color(AppColors.background),
      onRefresh: () async => setState(() {}),
      actions: [
        IconButton(
          tooltip: 'tracking_reports'.tr(),
          icon: Icon(Icons.assessment_outlined, color: Color(AppColors.secondaryButton)),
          onPressed: () => context.pushNamed(
            AppRoutes.trackingReports.name,
            pathParameters: {'lang': context.locale.languageCode},
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          // Time range.
          TrackingChipsRow(chips: [
            TrackingChoiceChip(
              label: 'tracking_live'.tr(),
              icon: Icons.sensors_rounded,
              selected: _mode == _MapMode.live,
              onTap: () => setState(() => _mode = _MapMode.live),
            ),
            TrackingChoiceChip(
              label: 'tracking_today'.tr(),
              icon: Icons.today_outlined,
              selected: _mode == _MapMode.today,
              onTap: () => setState(() => _mode = _MapMode.today),
            ),
            TrackingChoiceChip(
              label: dateLabel,
              icon: Icons.event_outlined,
              selected: _mode == _MapMode.date,
              onTap: _pickDate,
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          // Employees of this page, each with their route colour.
          TrackingChipsRow(chips: [
            TrackingChoiceChip(
              label: 'tracking_all_employees'.tr(namedArgs: {'n': '${employees.length}'}),
              selected: selected == null,
              onTap: () => setState(() => _selectedEmployeeId = null),
            ),
            for (var i = 0; i < employees.length; i++)
              TrackingChoiceChip(
                label: employees[i].getName(isArabic: isAr),
                dotColor: TrackingPalette.colorAt(i),
                selected: employees[i].employeeId == _selectedEmployeeId,
                onTap: () => setState(() => _selectedEmployeeId = employees[i].employeeId),
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
                  Positioned.fill(child: TrackingRouteMap(lines: lines, showAutoPoints: selected != null)),
                  PositionedDirectional(
                    top: AppSpacing.sm,
                    start: AppSpacing.sm,
                    child: _MapTag(
                      text: _mode == _MapMode.live
                          ? 'tracking_live_now'.tr()
                          : _mode == _MapMode.today
                              ? 'tracking_history_today'.tr()
                              : 'tracking_history_of'.tr(namedArgs: {'date': dateLabel}),
                      live: _mode == _MapMode.live,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Pagination (10 per page).
          Padding(
            padding: AppSpacing.pagePadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'tracking_employees_range'.tr(namedArgs: {
                      'from': '$from',
                      'to': '$to',
                      'total': '${TrackingDummyData.totalEmployees}',
                    }),
                    style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                  ),
                ),
                _PageButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: _page > 1 ? () => _goToPage(_page - 1) : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('$_page / $_pages', style: AppStyles.heading(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSpacing.sm),
                _PageButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _page < _pages ? () => _goToPage(_page + 1) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          Padding(
            padding: AppSpacing.pagePadding,
            child: selected == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSectionHeader(title: 'tracking_employees'.tr()),
                      const SizedBox(height: AppSpacing.sectionHeaderGap),
                      for (var i = 0; i < employees.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.cardGap),
                        _EmployeeRow(
                          employee: employees[i],
                          color: TrackingPalette.colorAt(i),
                          onTap: () => setState(() => _selectedEmployeeId = employees[i].employeeId),
                        ),
                      ],
                    ],
                  )
                : _EmployeeStatusCard(
                    employee: selected,
                    color: TrackingPalette.colorAt(selectedIndex),
                    sessions: routes[selected.employeeId]!,
                  ),
          ),
          const SizedBox(height: AppSpacing.listBottom),
        ],
      ),
    );
  }
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
          Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.statusTones(color).text)),
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

/// One employee in the "all employees" list: route colour ring, name, department, presence and
/// how long ago the last point arrived.
class _EmployeeRow extends StatelessWidget {
  final EmployeeTrackingSummaryModel employee;
  final Color color;
  final VoidCallback onTap;
  const _EmployeeRow({required this.employee, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    return AppCard.listItem(
      context: context,
      title: employee.getName(isArabic: isAr),
      subtitle: employee.getDepartment(isArabic: isAr),
      thirdLine: employee.getLastUpdatedText(isArabic: isAr),
      avatarUrl: employee.avatarUrl,
      avatarInitialsText: employee.getName(isArabic: isAr),
      accentColor: color,
      trailing: EmployeePresenceBadge(presence: EmployeeTrackingPresence.fromRaw(employee.status)),
      onTap: onTap,
    );
  }
}

/// The picked employee: presence, last update, current leg, then their key points in time order.
class _EmployeeStatusCard extends StatelessWidget {
  final EmployeeTrackingSummaryModel employee;
  final Color color;
  final List<TrackingSessionModel> sessions;
  const _EmployeeStatusCard({required this.employee, required this.color, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final active = employee.activeSession;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppCardLeadingAvatar(
                    imageUrl: employee.avatarUrl,
                    nameForInitials: employee.getName(isArabic: isAr),
                    borderColor: color,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.getName(isArabic: isAr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSizes.s2),
                        Text(employee.getDepartment(isArabic: isAr),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  EmployeePresenceBadge(presence: EmployeeTrackingPresence.fromRaw(employee.status)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: Color(AppColors.divider)),
              const SizedBox(height: AppSpacing.md),
              _InfoLine(
                icon: Icons.update_rounded,
                label: 'tracking_last_update'.tr(),
                value: employee.getLastUpdatedText(isArabic: isAr),
              ),
              const SizedBox(height: AppSpacing.sm),
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
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        AppSectionHeader(title: 'tracking_key_points'.tr()),
        const SizedBox(height: AppSpacing.sectionHeaderGap),
        TrackingKeyPointsTimeline(sessions: sessions, accent: color, showLeg: sessions.length > 1),
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
