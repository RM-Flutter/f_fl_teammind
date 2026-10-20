import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../data/models/tracking_status.enum.dart';

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
    if (st == RequestTrackingStatus.notRequired) {
      return const SizedBox.shrink();
    }

    final bool isAr = isArabic ?? LocalizationService.isArabic(context: context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: st.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: st.borderColor.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            st.icon,
            size: 13,
            color: st.textColor,
          ),
          const SizedBox(width: 4),
          Text(
            st.getLabel(isArabic: isAr),
            style: TextStyle(
              color: st.textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: isAr ? 'Cairo' : 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
