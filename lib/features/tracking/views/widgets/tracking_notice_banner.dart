import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../data/models/tracking_status.enum.dart';

/// A soft tinted notice with an icon, a title, a short hint and an optional action on the end.
/// Used for the location states (waiting / permission / offline) and the "points not uploaded"
/// notice, so every tracking notice looks the same.
class TrackingNoticeBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TrackingNoticeBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Banner for a location state; returns an empty box when the location is fine.
  static Widget forLocation(TrackingLocationState state, {VoidCallback? onOpenSettings}) {
    if (state == TrackingLocationState.ok) return const SizedBox.shrink();
    return TrackingNoticeBanner(
      icon: state.icon,
      color: state.color,
      title: state.title,
      message: state.message,
      actionLabel: state.hasSettingsAction ? 'tracking_open_settings'.tr() : null,
      onAction: state.hasSettingsAction ? onOpenSettings : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tones = AppColors.statusTones(color);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tones.tint,
        borderRadius: AppRadius.card,
        border: Border.all(color: tones.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: tones.text),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppStyles.heading(context)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: tones.text)),
                if (message != null && message!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(message!,
                      style: AppStyles.greyContent(context).copyWith(fontSize: 12, height: 1.4)),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: tones.text,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: const Size(0, 32),
              ),
              child: Text(actionLabel!,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
