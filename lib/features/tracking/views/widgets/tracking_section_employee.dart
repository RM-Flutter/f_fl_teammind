import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_section_header.widget.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import 'add_manual_point_modal.dart';
import 'tracking_key_points_timeline.dart';
import 'tracking_map_view_dialog.dart';
import 'tracking_notice_banner.dart';
import 'tracking_session_card.dart';
import 'tracking_status_badge.dart';

/// "Tracking" tab of the employee's own request (spec: mobile screen 2).
///
/// - Start / Stop: Start shows only when the request date matches today (or today is inside the
///   request's date range) and the request is not cancelled. Every Start / Stop is a new leg.
/// - Add key point: only while a leg is running; the title is optional; sent right away.
/// - Location problems (waiting / permission / limited / offline) are shown as a notice.
/// - "Sync now" shows only when points wait to be uploaded and no leg is running.
/// - Key points log + legs list, and the full route opens in a pop-up map.
///
/// UI only: all data is dummy ([TrackingDummyData]).
class TrackingSectionEmployee extends StatefulWidget {
  final dynamic request;
  final bool isDateMatched;
  final bool isRequestCancelled;

  /// Required tracking turns the badge orange until a leg is recorded.
  final bool isRequired;
  final TrackingLocationState locationState;
  final List<TrackingSessionModel>? initialSessions;
  final int initialUnsentPoints;

  /// Side padding; zero when the parent already pads the page (request details tabs).
  final EdgeInsetsGeometry padding;

  const TrackingSectionEmployee({
    super.key,
    required this.request,
    this.isDateMatched = true,
    this.isRequestCancelled = false,
    this.isRequired = true,
    this.locationState = TrackingLocationState.ok,
    this.initialSessions,
    this.initialUnsentPoints = 0,
    this.padding = AppSpacing.pagePadding,
  });

  @override
  State<TrackingSectionEmployee> createState() => _TrackingSectionEmployeeState();
}

class _TrackingSectionEmployeeState extends State<TrackingSectionEmployee> {
  late List<TrackingSessionModel> _sessions;
  late int _unsentPoints;

  @override
  void initState() {
    super.initState();
    _sessions = List.of(widget.initialSessions ?? [TrackingDummyData.session1, TrackingDummyData.activeSession]);
    _unsentPoints = widget.initialUnsentPoints;
  }

  TrackingSessionModel? get _activeSession {
    for (final s in _sessions) {
      if (s.isActive) return s;
    }
    return null;
  }

  RequestTrackingStatus get _status {
    if (_activeSession != null) return RequestTrackingStatus.active;
    if (_sessions.isNotEmpty) return RequestTrackingStatus.completed;
    return widget.isRequired ? RequestTrackingStatus.requiredNotStarted : RequestTrackingStatus.optionalNotStarted;
  }

  TrackingSessionModel _copy(
    TrackingSessionModel s, {
    DateTime? endedAt,
    TrackingSessionStatus? status,
    String? stopSource,
    List<TrackingPointModel>? points,
    int? manualPointsCount,
  }) {
    final pts = points ?? s.points;
    return TrackingSessionModel(
      id: s.id,
      requestId: s.requestId,
      employeeId: s.employeeId,
      startedAt: s.startedAt,
      endedAt: endedAt ?? s.endedAt,
      status: status ?? s.status,
      stopSource: stopSource ?? s.stopSource,
      lastPointAt: DateTime.now(),
      pointsCount: s.pointsCount + (pts.length - s.points.length),
      manualPointsCount: manualPointsCount ?? s.manualPointsCount,
      durationMinutes: endedAt != null ? endedAt.difference(s.startedAt).inMinutes : s.durationMinutes,
      points: pts,
    );
  }

  TrackingPointModel _pointNear(TrackingPointModel? last, {bool start = false, bool end = false, String? label}) {
    final base = last ?? TrackingDummyData.session1Start;
    final n = DateTime.now().millisecondsSinceEpoch;
    return TrackingPointModel(
      clientPointId: 'pt-$n',
      latitude: base.latitude + 0.0012,
      longitude: base.longitude + 0.0009,
      recordedAt: DateTime.now(),
      pointType: label != null ? 'manual' : 'auto',
      label: label,
      labelEn: label,
      isStartPoint: start,
      isEndPoint: end,
    );
  }

  void _start() {
    if (widget.locationState == TrackingLocationState.permissionRequired) {
      AlertsService.warning(
        context: context,
        title: 'tracking_permission_required',
        message: 'tracking_permission_required_hint',
      );
      return;
    }
    final last = _sessions.isNotEmpty && _sessions.last.points.isNotEmpty ? _sessions.last.points.last : null;
    setState(() {
      _sessions.add(TrackingSessionModel(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        requestId: 101,
        employeeId: 5,
        startedAt: DateTime.now(),
        status: TrackingSessionStatus.active,
        pointsCount: 1,
        points: [_pointNear(last, start: true)],
      ));
    });
    AlertsService.success(context: context, title: 'tracking_started', message: 'tracking_started_hint');
  }

  void _stop() {
    final active = _activeSession;
    if (active == null) return;
    final now = DateTime.now();
    setState(() {
      final i = _sessions.indexOf(active);
      _sessions[i] = _copy(
        active,
        endedAt: now,
        status: TrackingSessionStatus.completed,
        stopSource: 'manual',
        points: [...active.points, _pointNear(active.points.isNotEmpty ? active.points.last : null, end: true)],
      );
    });
    AlertsService.success(context: context, title: 'tracking_stopped', message: 'tracking_session_ended_route_saved');
  }

  void _addKeyPoint() {
    AddManualPointModal.show(context, onSubmit: (label) {
      final active = _activeSession;
      if (active == null) return;
      setState(() {
        final i = _sessions.indexOf(active);
        _sessions[i] = _copy(
          active,
          points: [...active.points, _pointNear(active.points.isNotEmpty ? active.points.last : null, label: label)],
          manualPointsCount: active.manualPointsCount + 1,
        );
      });
      AlertsService.success(context: context, title: 'tracking_point_saved', message: label);
    });
  }

  void _syncNow() {
    setState(() => _unsentPoints = 0);
    AlertsService.success(context: context, title: 'sync_now', message: 'all_points_synced_uploaded_successfully');
  }

  void _openFullMap() => TrackingMapViewDialog.show(
        context,
        title: 'full_request_route_map'.tr(),
        sessions: _sessions,
      );

  @override
  Widget build(BuildContext context) {
    final active = _activeSession;
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusCard(
            status: _status,
            isRequired: widget.isRequired,
            activeSession: active,
            activeLegNumber: active == null ? null : _sessions.indexOf(active) + 1,
            isRequestCancelled: widget.isRequestCancelled,
            isDateMatched: widget.isDateMatched,
            onStart: _start,
            onStop: _stop,
            onAddKeyPoint: _addKeyPoint,
          ),
          if (widget.locationState != TrackingLocationState.ok) ...[
            const SizedBox(height: AppSpacing.md),
            TrackingNoticeBanner.forLocation(widget.locationState, onOpenSettings: () {}),
          ],
          if (_unsentPoints > 0 && active == null) ...[
            const SizedBox(height: AppSpacing.md),
            TrackingNoticeBanner(
              icon: Icons.cloud_upload_outlined,
              color: Color(AppColors.warningYellow),
              title: 'tracking_unsent_points'.tr(namedArgs: {'n': '$_unsentPoints'}),
              message: 'tracking_unsent_points_hint'.tr(),
              actionLabel: 'sync_now'.tr(),
              onAction: _syncNow,
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(
            title: 'tracking_key_points'.tr(),
            actionText: 'tracking_view_on_map'.tr(),
            onViewAll: _sessions.isEmpty ? null : _openFullMap,
          ),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          TrackingKeyPointsTimeline(sessions: _sessions, showLeg: _sessions.length > 1),
          const SizedBox(height: AppSpacing.section),
          AppSectionHeader(title: 'tracking_legs_count'.tr(namedArgs: {'n': '${_sessions.length}'})),
          const SizedBox(height: AppSpacing.sectionHeaderGap),
          if (_sessions.isEmpty)
            AppCard(
              child: Text('no_tracking_sessions_recorded_yet_for_this'.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12.5)),
            )
          else
            for (var i = 0; i < _sessions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.cardGap),
              TrackingSessionCard(
                session: _sessions[i],
                sessionIndex: i,
                onOpenMap: () => TrackingMapViewDialog.show(
                  context,
                  title: 'route_for_session'.tr(namedArgs: {'index_1': '${i + 1}'}),
                  sessions: [_sessions[i]],
                ),
              ),
            ],
          const SizedBox(height: AppSpacing.section),
        ],
      ),
    );
  }
}

/// Top card: what tracking is for this request, its status, the running leg and the actions.
class _StatusCard extends StatelessWidget {
  final RequestTrackingStatus status;
  final bool isRequired;
  final TrackingSessionModel? activeSession;
  final int? activeLegNumber;
  final bool isRequestCancelled;
  final bool isDateMatched;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onAddKeyPoint;

  const _StatusCard({
    required this.status,
    required this.isRequired,
    required this.activeSession,
    required this.activeLegNumber,
    required this.isRequestCancelled,
    required this.isDateMatched,
    required this.onStart,
    required this.onStop,
    required this.onAddKeyPoint,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    final tones = AppColors.statusTones(accent);
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
                    const SizedBox(height: 2),
                    Text(
                      isRequired ? 'tracking_required_for_request'.tr() : 'tracking_optional_for_request'.tr(),
                      style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TrackingStatusBadge(status: status),
            ],
          ),
          if (activeSession != null) ...[
            const SizedBox(height: AppSpacing.md),
            _LiveStrip(session: activeSession!, legNumber: activeLegNumber ?? 1),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (isRequestCancelled)
            _Hint(icon: Icons.block_rounded, text: 'tracking_not_for_cancelled'.tr())
          else if (activeSession == null) ...[
            _PrimaryButton(
              icon: Icons.play_arrow_rounded,
              label: 'start_new_tracking_leg'.tr(),
              color: Color(AppColors.successGreen),
              onPressed: isDateMatched ? onStart : null,
            ),
            if (!isDateMatched) ...[
              const SizedBox(height: AppSpacing.sm),
              _Hint(icon: Icons.event_busy_outlined, text: 'tracking_only_on_request_date'.tr()),
            ],
          ] else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppButtonSize.height,
                    child: OutlinedButton.icon(
                      onPressed: onAddKeyPoint,
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
                    onPressed: onStop,
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
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
