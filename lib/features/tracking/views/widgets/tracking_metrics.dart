import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

/// One figure of the tracking summary: soft icon square, the value and its label.
class TrackingMetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const TrackingMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tones = AppColors.statusTones(color);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tones.tint, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(icon, size: 18, color: tones.text),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.heading(context).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.greyContent(context).copyWith(fontSize: 11, height: 1.25),
          ),
        ],
      ),
    );
  }
}

/// Active hours, start / stop count and (when work hours are enabled) the hours inside work
/// hours, side by side (spec: "Active Hours & Start Count", the anti-cheat indicator).
class TrackingMetricsRow extends StatelessWidget {
  final double activeHours;
  final int startStopCount;

  /// Null when the company did not enable work hours.
  final double? hoursWithinWorkHours;

  const TrackingMetricsRow({
    super.key,
    required this.activeHours,
    required this.startStopCount,
    this.hoursWithinWorkHours,
  });

  static String formatHours(double h) {
    final totalMinutes = (h * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return 'mins_2'.tr(namedArgs: {'minutes': '$minutes'});
    if (minutes == 0) return 'hrs'.tr(namedArgs: {'hours': '$hours'});
    return 'h_m'.tr(namedArgs: {'hours': '$hours', 'remaining_minutes': '$minutes'});
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      TrackingMetricTile(
        icon: Icons.timer_outlined,
        value: formatHours(activeHours),
        label: 'active_hours'.tr(),
        color: Color(AppColors.buttons),
      ),
      TrackingMetricTile(
        icon: Icons.repeat_rounded,
        value: '$startStopCount',
        label: 'tracking_start_stop_count'.tr(),
        color: Color(AppColors.secondaryButton),
      ),
      if (hoursWithinWorkHours != null)
        TrackingMetricTile(
          icon: Icons.work_history_outlined,
          value: formatHours(hoursWithinWorkHours!),
          label: 'in_work_hours'.tr(),
          color: Color(AppColors.successGreen),
        ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}
