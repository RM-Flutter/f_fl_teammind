import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_shortcut_card.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import '../widgets/tracking_choice_chip.dart';
import '../widgets/tracking_section_employee.dart';
import '../widgets/tracking_section_manager.dart';
import 'live_group_map_screen.dart';
import 'tracking_reports_screen.dart';

/// Design preview of request tracking (route `trackingDemoHub`). Every screen of the spec with
/// dummy data, so the design can be reviewed before the back end is ready.
class TrackingDemoHubScreen extends StatelessWidget {
  const TrackingDemoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    final entries = <Widget>[
      AppShortcutCard(
        icon: Icons.person_pin_circle_outlined,
        title: 'tracking_preview_employee'.tr(),
        subtitle: 'tracking_preview_employee_hint'.tr(),
        onTap: () => open(const _EmployeePreview()),
      ),
      AppShortcutCard(
        icon: Icons.insights_rounded,
        title: 'tracking_preview_manager'.tr(),
        subtitle: 'tracking_preview_manager_hint'.tr(),
        onTap: () => open(const _ManagerPreview()),
      ),
      AppShortcutCard(
        icon: Icons.map_outlined,
        title: 'tracking_team_map'.tr(),
        subtitle: 'tracking_team_map_hint'.tr(),
        onTap: () => open(const LiveGroupMapScreen()),
      ),
      AppShortcutCard(
        icon: Icons.assessment_outlined,
        title: 'tracking_reports'.tr(),
        subtitle: 'tracking_reports_hint'.tr(),
        onTap: () => open(const TrackingReportsScreen()),
      ),
    ];
    return TemplatePage(
      pageContext: context,
      title: 'tracking'.tr(),
      backgroundColor: Color(AppColors.background),
      onRefresh: () async {},
      body: Padding(
        padding: AppSpacing.listPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('tracking_preview_note'.tr(), style: AppStyles.greyContent(context).copyWith(fontSize: 12.5, height: 1.5)),
            const SizedBox(height: AppSpacing.md),
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.cardGap),
              entries[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// The employee's tracking tab in each state of the spec.
enum _Scenario { running, notStarted, otherDate, unsent, permissionLimited, permissionRequired, offline, cancelled }

class _EmployeePreview extends StatefulWidget {
  const _EmployeePreview();

  @override
  State<_EmployeePreview> createState() => _EmployeePreviewState();
}

class _EmployeePreviewState extends State<_EmployeePreview> {
  _Scenario _scenario = _Scenario.running;

  String _label(_Scenario s) => switch (s) {
        _Scenario.running => 'tracking_active'.tr(),
        _Scenario.notStarted => 'required_not_started'.tr(),
        _Scenario.otherDate => 'tracking_preview_other_date'.tr(),
        _Scenario.unsent => 'tracking_preview_unsent'.tr(),
        _Scenario.permissionLimited => 'tracking_permission_limited'.tr(),
        _Scenario.permissionRequired => 'tracking_permission_required'.tr(),
        _Scenario.offline => 'tracking_offline'.tr(),
        _Scenario.cancelled => 'tracking_preview_cancelled'.tr(),
      };

  @override
  Widget build(BuildContext context) {
    final List<TrackingSessionModel> sessions = switch (_scenario) {
      _Scenario.notStarted || _Scenario.otherDate || _Scenario.permissionRequired => [],
      _Scenario.unsent || _Scenario.cancelled => [TrackingDummyData.session1],
      _ => [TrackingDummyData.session1, TrackingDummyData.activeSession],
    };
    final location = switch (_scenario) {
      _Scenario.permissionLimited => TrackingLocationState.permissionLimited,
      _Scenario.permissionRequired => TrackingLocationState.permissionRequired,
      _Scenario.offline => TrackingLocationState.offline,
      _ => TrackingLocationState.ok,
    };
    return TemplatePage(
      pageContext: context,
      title: 'tracking_preview_employee'.tr(),
      backgroundColor: Color(AppColors.background),
      onRefresh: () async {},
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          TrackingChipsRow(chips: [
            for (final s in _Scenario.values)
              TrackingChoiceChip(
                label: _label(s),
                selected: s == _scenario,
                onTap: () => setState(() => _scenario = s),
              ),
          ]),
          const SizedBox(height: AppSpacing.md),
          TrackingSectionEmployee(
            key: ValueKey(_scenario),
            request: null,
            initialSessions: sessions,
            isDateMatched: _scenario != _Scenario.otherDate,
            isRequestCancelled: _scenario == _Scenario.cancelled,
            locationState: location,
            initialUnsentPoints: _scenario == _Scenario.unsent || _scenario == _Scenario.offline ? 7 : 0,
          ),
        ],
      ),
    );
  }
}

class _ManagerPreview extends StatelessWidget {
  const _ManagerPreview();

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      pageContext: context,
      title: 'tracking_preview_manager'.tr(),
      backgroundColor: Color(AppColors.background),
      onRefresh: () async {},
      body: const Padding(
        padding: EdgeInsets.only(top: AppSpacing.md),
        child: TrackingSectionManager(request: null),
      ),
    );
  }
}
