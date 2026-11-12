import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/models/tracking_session.model.dart';

/// One row of the key points log: a start, end or manual point and the leg it belongs to.
class _KeyPoint {
  final TrackingPointModel point;
  final int legNumber;
  const _KeyPoint(this.point, this.legNumber);
}

/// "Key points" log of a request or an employee: the start and end of every leg and every manual
/// point with its title, in time order (spec: request detail + group map status card).
/// Managers often need only these points, not every GPS sample.
class TrackingKeyPointsTimeline extends StatelessWidget {
  final List<TrackingSessionModel> sessions;

  /// Show only the latest N points (null = all).
  final int? maxItems;

  /// Colour of manual points (the employee colour on the group map).
  final Color? accent;

  /// Show the "Leg n" tag on each row (hide it when there is a single leg).
  final bool showLeg;

  const TrackingKeyPointsTimeline({
    super.key,
    required this.sessions,
    this.maxItems,
    this.accent,
    this.showLeg = true,
  });

  List<_KeyPoint> get _items {
    final list = <_KeyPoint>[];
    for (var i = 0; i < sessions.length; i++) {
      for (final p in sessions[i].points) {
        if (p.isStartPoint || p.isEndPoint || p.isManual) list.add(_KeyPoint(p, i + 1));
      }
    }
    list.sort((a, b) => a.point.recordedAt.compareTo(b.point.recordedAt));
    if (maxItems != null && list.length > maxItems!) {
      return list.sublist(list.length - maxItems!);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.flag_outlined, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('tracking_no_key_points'.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12.5)),
            ),
          ],
        ),
      );
    }
    final accentColor = accent ?? Color(AppColors.buttons);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _TimelineRow(
              item: items[i],
              accent: accentColor,
              isLast: i == items.length - 1,
              showLeg: showLeg,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _KeyPoint item;
  final Color accent;
  final bool isLast;
  final bool showLeg;
  const _TimelineRow({required this.item, required this.accent, required this.isLast, required this.showLeg});

  @override
  Widget build(BuildContext context) {
    final p = item.point;
    final Color color = p.isStartPoint
        ? Color(AppColors.successGreen)
        : p.isEndPoint
            ? Color(AppColors.failureRed)
            : accent;
    final IconData icon = p.isStartPoint
        ? Icons.play_arrow_rounded
        : p.isEndPoint
            ? Icons.stop_rounded
            : Icons.flag_rounded;
    final String title = p.isStartPoint
        ? 'tracking_leg_started'.tr()
        : p.isEndPoint
            ? 'tracking_leg_ended'.tr()
            : p.getDisplayLabel(isArabic: context.locale.languageCode == 'ar');
    final time = DateFormat('hh:mm a', context.locale.languageCode).format(p.recordedAt);
    final tones = AppColors.statusTones(color);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Marker + the line down to the next point.
          SizedBox(
            width: AppSizes.s28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: tones.tint, shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: tones.text),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: AppSizes.s2),
                      color: Color(AppColors.border),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.s4, bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(
                      fontSize: 13,
                      fontWeight: p.isManual ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.s2),
                  Wrap(
                    spacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(time, style: AppStyles.greyContent(context).copyWith(fontSize: 11.5)),
                      if (showLeg)
                        Text('tracking_leg_n'.tr(namedArgs: {'n': '${item.legNumber}'}),
                            style: AppStyles.greyContent(context).copyWith(fontSize: 11.5)),
                      if (p.isManual && !p.isStartPoint && !p.isEndPoint)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s1),
                          decoration: BoxDecoration(
                            color: tones.tint,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text('tracking_manual_tag'.tr(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tones.text)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
