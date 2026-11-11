import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import 'tracking_status_badge.dart';

/// One tracking leg (session) of a request: leg number, time range, status, duration and point
/// counts. Tapping it opens the leg on the map.
class TrackingSessionCard extends StatelessWidget {
  final TrackingSessionModel session;
  final int sessionIndex;
  final VoidCallback? onOpenMap;

  const TrackingSessionCard({
    super.key,
    required this.session,
    required this.sessionIndex,
    this.onOpenMap,
  });

  String? _stopNote() {
    switch (session.stopSource) {
      case 'auto_timeout':
        return 'tracking_stopped_auto_timeout'.tr();
      case 'request_closed':
        return 'tracking_stopped_request_closed'.tr();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final fmt = DateFormat('hh:mm a', lang);
    final tones = AppColors.statusTones(session.status.color);
    final range = session.endedAt != null
        ? '${fmt.format(session.startedAt)} – ${fmt.format(session.endedAt!)}'
        : '${fmt.format(session.startedAt)} – ${'tracking_now'.tr()}';
    final note = _stopNote();

    return AppCard(
      animateIn: true,
      onTap: onOpenMap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tones.tint, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Text('${sessionIndex + 1}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: tones.text)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('tracking_leg_n'.tr(namedArgs: {'n': '${sessionIndex + 1}'}),
                        style: AppStyles.heading(context).copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(range, style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TrackingSessionStatusBadge(status: session.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Meta(icon: Icons.timer_outlined, text: session.getDurationFormatted()),
              const SizedBox(width: AppSpacing.lg),
              _Meta(
                  icon: Icons.scatter_plot_outlined,
                  text: 'tracking_points_n'.tr(namedArgs: {'n': '${session.pointsCount}'})),
              const SizedBox(width: AppSpacing.lg),
              _Meta(
                  icon: Icons.flag_outlined,
                  text: 'tracking_manual_n'.tr(namedArgs: {'n': '${session.manualPointsCount}'})),
              const Spacer(),
              if (onOpenMap != null)
                Icon(Icons.map_outlined, size: 20, color: Color(AppColors.buttons)),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.statusTones(TrackingSessionStatus.interrupted.color).text),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(note,
                      style: AppStyles.greyContent(context).copyWith(fontSize: 11.5)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF8A8FA3)),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
      ],
    );
  }
}
