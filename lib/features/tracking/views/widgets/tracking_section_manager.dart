import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import '../../controllers/request_tracking_controller.dart';
import 'request_tracking_tab.dart';
import 'tracking_key_points_timeline.dart';
import 'tracking_metrics.dart';
import 'tracking_session_card.dart';
import 'tracking_status_badge.dart';

/// "Tracking" tab of another employee's request, for the manager / HR (API doc screen 3).
///
/// From `GET /requests/{id}`: status, Active Hours, Start / Stop count, hours within work hours
/// (only when not null), key points and sessions. "View full route" shows only when
/// `has_sessions`. The manager never starts or stops the employee's tracking.
/// When tracking is required and not started, approval is refused by the server, so a warning
/// shows here (and above the approve button).
class TrackingSectionManager extends StatelessWidget {
  final RequestTrackingController controller;

  /// Side padding; zero when the parent already pads the page (request details tabs).
  final EdgeInsetsGeometry padding;

  const TrackingSectionManager({
    super.key,
    required this.controller,
    this.padding = AppSpacing.pagePadding,
  });

  @override
  Widget build(BuildContext context) {
    final tracking = controller.tracking;
    final legs = controller.sessions;
    final status = tracking.status;
    final accent = Color(AppColors.secondaryButton);
    final tones = AppColors.statusTones(accent);

    void openFullMap() => openTrackingRouteMap(context, controller);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: tones.tint, borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Icon(Icons.insights_rounded, color: tones.text, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('tracking_summary'.tr(),
                              style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSizes.s2),
                          Text('tracking_summary_hint'.tr(),
                              style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TrackingStatusBadge(status: status),
                  ],
                ),
                if (tracking.blocksApproval) ...[
                  const SizedBox(height: AppSpacing.md),
                  const TrackingApprovalWarning(),
                ],
                if (tracking.hasSessions) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: AppButtonSize.height,
                    child: ElevatedButton.icon(
                      onPressed: controller.isBusy ? null : openFullMap,
                      icon: const Icon(Icons.map_outlined, size: 20),
                      label: Text('view_full_route_on_map'.tr(),
                          style: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.buttons),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TrackingMetricsRow(
            activeHours: tracking.activeHours,
            startStopCount: tracking.startCount,
            hoursWithinWorkHours: tracking.workHours,
          ),
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(title: 'tracking_key_points'.tr()),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          TrackingKeyPointsTimeline(sessions: legs, showLeg: legs.length > 1),
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(title: 'tracking_legs_count'.tr(namedArgs: {'n': '${legs.length}'})),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          if (legs.isEmpty)
            AppCard(
              child: Text('no_tracking_legs_recorded_for_this_request'.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12.5)),
            )
          else
            for (var i = 0; i < legs.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.cardGap),
              TrackingSessionCard(
                session: legs[i],
                sessionIndex: i,
                onOpenMap: controller.isBusy
                    ? null
                    : () => openTrackingRouteMap(context, controller, sessionId: legs[i].id, legIndex: i),
              ),
            ],
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }
}
