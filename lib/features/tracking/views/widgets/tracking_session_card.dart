import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/models/tracking_session.model.dart';
import 'manual_point_tile.dart';
import 'package:app_test/core/constants/app_design.dart';

class TrackingSessionCard extends StatefulWidget {
  final TrackingSessionModel session;
  final int sessionIndex;
  final VoidCallback? onOpenMap;

  const TrackingSessionCard({
    super.key,
    required this.session,
    required this.sessionIndex,
    this.onOpenMap,
  });

  @override
  State<TrackingSessionCard> createState() => _TrackingSessionCardState();
}

class _TrackingSessionCardState extends State<TrackingSessionCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);
    final session = widget.session;
    final startTimeStr = DateFormat('hh:mm a', isAr ? 'ar' : 'en').format(session.startedAt);
    final endTimeStr = session.endedAt != null
        ? DateFormat('hh:mm a', isAr ? 'ar' : 'en').format(session.endedAt!)
        : ('ongoing'.tr());

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s12),
      decoration: ShapeDecoration(
        color: Color(AppColors.cardBackground), // 0xFFF1F6FF
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(
            color: session.isActive
                ? const Color(0xff2D6A4F).withOpacity(0.4)
                : Color(AppColors.border),
            width: session.isActive ? 1.5 : 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(AppColors.disableButton).withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sm)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: session.status.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      session.isActive
                          ? Icons.radio_button_checked
                          : Icons.check_circle_outline,
                      color: session.status.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('route_leg'.tr(namedArgs: {'session_index_1': '${widget.sessionIndex + 1}'}),
                              style: AppStyles.content(context).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(AppColors.titleText),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: session.status.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Text(
                                session.status.getLabel(isArabic: isAr),
                                style: TextStyle(
                                  color: session.status.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$startTimeStr - $endTimeStr (${session.getDurationFormatted(isArabic: isAr)})',
                          style: AppStyles.subtitleContent(context).copyWith(
                            fontSize: 11,
                            color: const Color(0xff606060),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Color(AppColors.iconSecondary),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Divider(color: Color(AppColors.divider), height: 1),
            ),
            const SizedBox(height: 10),
            // Summary Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _SummaryMiniChip(
                    icon: Icons.pin_drop_outlined,
                    label: 'points_recorded'.tr(namedArgs: {'points_count': '${session.pointsCount}'}),
                  ),
                  const SizedBox(width: 8),
                  _SummaryMiniChip(
                    icon: Icons.flag_outlined,
                    label: 'milestones'.tr(namedArgs: {'length': '${session.manualPoints.length}'}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Timeline of points
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: session.manualPoints.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('no_points_recorded_yet_for_this_leg'.tr(),
                        style: AppStyles.hintContent(context).copyWith(fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: session.manualPoints.length,
                      itemBuilder: (context, idx) {
                        return ManualPointTile(
                          point: session.manualPoints[idx],
                          isLast: idx == session.manualPoints.length - 1,
                        );
                      },
                    ),
            ),
            if (widget.onOpenMap != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(AppColors.buttons),
                      side: BorderSide(color: Color(AppColors.buttons)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: widget.onOpenMap,
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: Text('view_leg_route_on_map'.tr(),
                      style: AppStyles.content(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.buttons),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SummaryMiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryMiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Color(AppColors.border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Color(AppColors.iconSecondary)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.content(context).copyWith(
              fontSize: 11,
              color: const Color(0xff333333),
            ),
          ),
        ],
      ),
    );
  }
}
