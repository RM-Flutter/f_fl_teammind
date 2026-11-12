import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import 'tracking_key_points_timeline.dart';
import 'tracking_map_view_dialog.dart';
import 'tracking_metrics.dart';
import 'tracking_session_card.dart';
import 'tracking_status_badge.dart';

/// "Tracking" tab of another employee's request, for the manager / HR (spec: mobile screen 3).
///
/// Shows the request's tracking status, Active Hours, Start / Stop count and (when work hours are
/// enabled) the hours inside work hours, the key points log and the legs. "View full route" opens
/// the whole route on the map and shows only when there is at least one leg.
/// Cancelling tracking is a back-office (web) action, so it is not here.
///
/// UI only: all data is dummy ([TrackingDummyData]).
class TrackingSectionManager extends StatelessWidget {
  final dynamic request;
  final RequestTrackingStatus status;
  final List<TrackingSessionModel>? sessions;
  final double activeHours;
  final int startStopCount;

  /// Null when the company did not enable work hours.
  final double? hoursWithinWorkHours;

  /// Side padding; zero when the parent already pads the page (request details tabs).
  final EdgeInsetsGeometry padding;

  const TrackingSectionManager({
    super.key,
    required this.request,
    this.status = RequestTrackingStatus.active,
    this.sessions,
    this.activeHours = 3.08,
    this.startStopCount = 2,
    this.hoursWithinWorkHours = 2.75,
    this.padding = AppSpacing.pagePadding,
  });

  @override
  Widget build(BuildContext context) {
    final legs = sessions ?? [TrackingDummyData.session1, TrackingDummyData.activeSession];
    final accent = Color(AppColors.secondaryButton);
    final tones = AppColors.statusTones(accent);

    void openFullMap() => TrackingMapViewDialog.show(
          context,
          title: 'full_request_route_map'.tr(),
          sessions: legs,
        );

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
                if (legs.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: AppButtonSize.height,
                    child: ElevatedButton.icon(
                      onPressed: openFullMap,
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
            activeHours: activeHours,
            startStopCount: startStopCount,
            hoursWithinWorkHours: hoursWithinWorkHours,
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
                onOpenMap: () => TrackingMapViewDialog.show(
                  context,
                  title: 'route_for_session'.tr(namedArgs: {'index_1': '${i + 1}'}),
                  sessions: [legs[i]],
                ),
              ),
            ],
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }
}
