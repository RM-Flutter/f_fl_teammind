import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/location_tracking/location_tracking_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import 'package:provider/provider.dart';
import '../../controllers/request_tracking_controller.dart';
import '../../data/models/request_tracking.model.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import 'add_manual_point_modal.dart';
import 'tracking_key_points_timeline.dart';
import 'request_tracking_tab.dart';
import 'tracking_notice_banner.dart';
import 'tracking_session_card.dart';
import 'tracking_status_badge.dart';

/// "Tracking" tab of the employee's own request (API doc screen 2).
///
/// Everything comes from `GET /requests/{id}` through [RequestTrackingController]:
/// - Start shows when `tracking.can_start`; otherwise, with no open session, `can_start_reason`.
///   The app never works out on its own whether tracking may start.
/// - Stop and "Add key point" show while `active_session_id` is set.
/// - Location problems (waiting / permission / limited / offline) come from the phone's recorder.
/// - "Sync now" shows when points of this request wait in the queue and no session is open.
/// - Key points log (`main_points`), sessions, and the full route in a pop-up map (`/path`).
/// On the web (no background location) the employee sees the data, but Start / Stop are hidden.
class TrackingSectionEmployee extends StatelessWidget {
  final RequestTrackingController controller;

  /// Side padding; zero when the parent already pads the page (request details tabs).
  final EdgeInsetsGeometry padding;

  const TrackingSectionEmployee({
    super.key,
    required this.controller,
    this.padding = AppSpacing.pagePadding,
  });

  static TrackingLocationState _locationState(TrackingLocationStatus s) {
    switch (s) {
      case TrackingLocationStatus.ok:
        return TrackingLocationState.ok;
      case TrackingLocationStatus.waitingForLocation:
        return TrackingLocationState.waitingForLocation;
      case TrackingLocationStatus.permissionRequired:
        return TrackingLocationState.permissionRequired;
      case TrackingLocationStatus.permissionLimited:
        return TrackingLocationState.permissionLimited;
      case TrackingLocationStatus.offline:
        return TrackingLocationState.offline;
    }
  }

  void _addKeyPoint(BuildContext context) {
    AddManualPointModal.show(context, onSubmit: (label) => controller.addKeyPoint(context, label));
  }

  @override
  Widget build(BuildContext context) {
    final recorder = context.watch<LocationTrackingService>();
    final tracking = controller.tracking;
    final sessions = controller.sessions;
    final active = controller.activeSession;
    final canAct = LocationTrackingService.isSupported;
    final unsent = recorder.pendingCount(controller.requestId);
    final recordingHere = active != null && recorder.activeSessionId == active.id;
    final location = recordingHere ? _locationState(recorder.status) : TrackingLocationState.ok;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(
            tracking: tracking,
            activeSession: active,
            activeLegNumber: active == null ? null : sessions.indexOf(active) + 1,
            canAct: canAct,
            busy: controller.isBusy,
            onStart: () => controller.start(context),
            onStop: () => controller.stop(context),
            onAddKeyPoint: () => _addKeyPoint(context),
          ),
          if (location != TrackingLocationState.ok) ...[
            const SizedBox(height: AppSpacing.md),
            TrackingNoticeBanner.forLocation(location, onOpenSettings: recorder.openSettings),
          ],
          if (canAct && unsent > 0 && tracking.activeSessionId == null) ...[
            const SizedBox(height: AppSpacing.md),
            TrackingNoticeBanner(
              icon: Icons.cloud_upload_outlined,
              color: Color(AppColors.warningYellow),
              title: 'tracking_unsent_points'.tr(namedArgs: {'n': '$unsent'}),
              message: 'tracking_unsent_points_hint'.tr(),
              actionLabel: 'sync_now'.tr(),
              onAction: controller.isBusy ? null : () => controller.syncNow(context),
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(
            title: 'tracking_key_points'.tr(),
            actionText: 'tracking_view_on_map'.tr(),
            onViewAll: tracking.hasSessions && !controller.isBusy ? () => openTrackingRouteMap(context, controller) : null,
          ),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          TrackingKeyPointsTimeline(sessions: sessions, showLeg: sessions.length > 1),
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(title: 'tracking_legs_count'.tr(namedArgs: {'n': '${sessions.length}'})),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          if (sessions.isEmpty)
            AppCard(
              child: Text('no_tracking_sessions_recorded_yet_for_this'.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12.5)),
            )
          else
            for (var i = 0; i < sessions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.cardGap),
              TrackingSessionCard(
                session: sessions[i],
                sessionIndex: i,
                onOpenMap: controller.isBusy
                    ? null
                    : () => openTrackingRouteMap(context, controller, sessionId: sessions[i].id, legIndex: i),
              ),
            ],
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }
}

/// Top card: what tracking is for this request, its status, the running session and the actions.
class _StatusCard extends StatelessWidget {
  final RequestTrackingInfoModel tracking;
  final TrackingSessionModel? activeSession;
  final int? activeLegNumber;

  /// False on the web: the data shows, the actions do not.
  final bool canAct;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onAddKeyPoint;

  const _StatusCard({
    required this.tracking,
    required this.activeSession,
    required this.activeLegNumber,
    required this.canAct,
    required this.busy,
    required this.onStart,
    required this.onStop,
    required this.onAddKeyPoint,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    final tones = AppColors.statusTones(accent);
    final isRunning = tracking.activeSessionId != null;
    final reason = tracking.canStartReason;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: tones.tint, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(Icons.location_on_outlined, color: tones.text, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('request_location_tracking'.tr(),
                        style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSizes.s2),
                    Text(
                      tracking.isRequired ? 'tracking_required_for_request'.tr() : 'tracking_optional_for_request'.tr(),
                      style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TrackingStatusBadge(status: tracking.status),
            ],
          ),
          if (activeSession != null) ...[
            const SizedBox(height: AppSpacing.md),
            _LiveStrip(session: activeSession!, legNumber: activeLegNumber ?? 1),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (!canAct)
            _Hint(icon: Icons.phone_iphone_rounded, text: 'tracking_mobile_only'.tr())
          else if (isRunning)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppButtonSize.height,
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onAddKeyPoint,
                      icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                      label: Text('tracking_key_point'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(AppColors.secondaryButton),
                        side: BorderSide(color: Color(AppColors.secondaryButton)),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PrimaryButton(
                    icon: Icons.stop_rounded,
                    label: 'stop_leg'.tr(),
                    color: Color(AppColors.failureRed),
                    onPressed: busy ? null : onStop,
                  ),
                ),
              ],
            )
          else if (tracking.canStart)
            _PrimaryButton(
              icon: Icons.play_arrow_rounded,
              label: 'start_new_tracking_leg'.tr(),
              color: Color(AppColors.successGreen),
              onPressed: busy ? null : onStart,
            )
          else if (reason != null && reason.isNotEmpty)
            _Hint(icon: Icons.event_busy_outlined, text: reason),
        ],
      ),
    );
  }
}

/// "Leg 2 running · 1 h 20 m" with a live dot, under the title while a leg is active.
class _LiveStrip extends StatelessWidget {
  final TrackingSessionModel session;
  final int legNumber;
  const _LiveStrip({required this.session, required this.legNumber});

  @override
  Widget build(BuildContext context) {
    final green = Color(AppColors.successGreen);
    final tones = AppColors.statusTones(green);
    final lastAgo = session.lastPointAt == null ? null : DateTime.now().difference(session.lastPointAt!).inMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSizes.s10),
      decoration: BoxDecoration(color: tones.tint, borderRadius: AppRadius.card),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: green.withValues(alpha: 0.25), shape: BoxShape.circle),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: green, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'tracking_leg_running'.tr(namedArgs: {'n': '$legNumber', 'duration': session.getDurationFormatted()}),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tones.text),
            ),
          ),
          if (lastAgo != null)
            Text('tracking_last_point_ago'.tr(namedArgs: {'min': '$lastAgo'}),
                style: AppStyles.greyContent(context).copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.icon, required this.label, required this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppButtonSize.height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Color(AppColors.disableButton),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Hint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppField.iconColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppStyles.greyContent(context).copyWith(fontSize: 12))),
      ],
    );
  }
}
