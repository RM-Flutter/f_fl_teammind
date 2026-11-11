import 'package:flutter/material.dart';

import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import '../../data/models/tracking_status.enum.dart';

/// Tracking status of a request, as the app's standard status pill ([AppStatusBadge]).
/// Hidden when the request has no tracking at all.
class TrackingStatusBadge extends StatelessWidget {
  final RequestTrackingStatus? status;
  final String? rawStatus;
  final bool? isArabic;

  const TrackingStatusBadge({
    super.key,
    this.status,
    this.rawStatus,
    this.isArabic,
  });

  RequestTrackingStatus get resolvedStatus {
    if (status != null) return status!;
    if (rawStatus == null) return RequestTrackingStatus.notRequired;
    final s = rawStatus!.trim().toLowerCase();
    if (s.contains('active')) return RequestTrackingStatus.active;
    if (s.contains('completed')) return RequestTrackingStatus.completed;
    if (s.contains('missing')) return RequestTrackingStatus.requiredMissing;
    if (s.contains('required') && s.contains('not_started')) {
      return RequestTrackingStatus.requiredNotStarted;
    }
    if (s.contains('optional')) return RequestTrackingStatus.optionalNotStarted;
    return RequestTrackingStatus.notRequired;
  }

  @override
  Widget build(BuildContext context) {
    final st = resolvedStatus;
    if (st == RequestTrackingStatus.notRequired) return const SizedBox.shrink();
    return AppStatusBadge(label: st.getLabel(), color: st.baseColor, icon: st.icon);
  }
}

/// Status of one tracking session (leg), as the app's standard status pill.
class TrackingSessionStatusBadge extends StatelessWidget {
  final TrackingSessionStatus status;
  const TrackingSessionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) =>
      AppStatusBadge(label: status.getLabel(), color: status.color, icon: status.icon);
}

/// Live presence of an employee on the group map, as the app's standard status pill.
class EmployeePresenceBadge extends StatelessWidget {
  final EmployeeTrackingPresence presence;
  const EmployeePresenceBadge({super.key, required this.presence});

  @override
  Widget build(BuildContext context) =>
      AppStatusBadge(label: presence.label, color: presence.color, icon: presence.icon);
}
