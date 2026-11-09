import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_design.dart';

/// Unified pill-shaped status badge used across all cards in the app.
/// Matches the reference style in `TeamMemberStatusCard`:
/// - soft tinted background and a light 1px border, text/icon darkened for contrast
///   (`AppColors.statusTones`)
/// - `AppRadius.lg` (or `pill`) border radius
/// - `horizontal: 10, vertical: 5` padding
/// - 12px icon + 4px gap + 11px w600 text
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  /// Icon after the text (e.g. an arrow that says "open"). Mirrors itself in RTL.
  final IconData? trailingIcon;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.trailingIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.fontSize = 11,
    this.iconSize = 12,
  });

  /// Builds a unified [AppStatusBadge] automatically from any status string in the app.
  factory AppStatusBadge.fromStatus({
    Key? key,
    required String? status,
    String? customLabel,
    Color? customColor,
    IconData? customIcon,
    EdgeInsetsGeometry? padding,
  }) {
    final normalized = (status ?? '').trim().toLowerCase();
    final resolvedColor = customColor ?? colorForStatus(normalized);
    final resolvedIcon = customIcon ?? iconForStatus(normalized);
    final resolvedLabel =
        customLabel ?? labelForStatus(status ?? '-', normalized);

    return AppStatusBadge(
      key: key,
      label: resolvedLabel,
      color: resolvedColor,
      icon: resolvedIcon,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }

  static Color colorForStatus(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'present':
      case 'approved':
      case 'completed':
      case 'active':
      case 'evaluated':
      case 'public':
      case 'paid':
      case 'reward':
      case 'rewards':
      case 'addition':
      case 'check_in':
      case 'in':
        return Color(AppColors.successGreen);

      case 'clocked_out':
      case 'seen':
      case 'in_progress':
      case 'processing':
      case 'check_out':
      case 'out':
        return Color(AppColors.helpBlue);

      case 'absent':
      case 'refused':
      case 'rejected':
      case 'canceled':
      case 'cancelled':
      case 'action_required':
      case 'cancel_approval_required':
      case 'private':
      case 'penalty':
      case 'penalties':
      case 'deduction':
      case 'expired':
      case 'failed':
        return Color(AppColors.failureRed);

      case 'vacation':
      case 'on_leave':
      case 'waiting':
      case 'waiting_seen':
      case 'waiting_cancel':
      case 'pending':
      case 'pending_evaluation':
      case 'act_as_someone':
      case 'cancellation_pending':
      case 'premium':
      case 'hold':
        return Color(AppColors.warningYellow);

      case 'weekend':
      case 'closed':
      case 'inactive':
      case 'archived':
      default:
        return Color(AppColors.tabInactive);
    }
  }

  static IconData iconForStatus(String normalizedStatus) {
    switch (normalizedStatus) {
      case 'present':
      case 'approved':
      case 'completed':
      case 'active':
      case 'evaluated':
      case 'paid':
      case 'reward':
      case 'rewards':
      case 'addition':
        return Icons.check_circle_outline_rounded;

      case 'clocked_out':
      case 'check_out':
      case 'out':
        return Icons.logout_rounded;

      case 'check_in':
      case 'in':
        return Icons.login_rounded;

      case 'seen':
      case 'in_progress':
      case 'processing':
        return Icons.access_time_rounded;

      case 'absent':
      case 'refused':
      case 'rejected':
      case 'canceled':
      case 'cancelled':
      case 'penalty':
      case 'penalties':
      case 'deduction':
      case 'expired':
      case 'failed':
        return Icons.cancel_outlined;

      case 'action_required':
        return Icons.gavel_rounded;

      case 'act_as_someone':
        return Icons.manage_accounts_rounded;

      case 'vacation':
      case 'on_leave':
        return Icons.beach_access_rounded;

      case 'waiting':
      case 'waiting_seen':
      case 'waiting_cancel':
      case 'pending':
      case 'pending_evaluation':
      case 'cancellation_pending':
      case 'hold':
        return Icons.hourglass_top_rounded;

      case 'premium':
        return Icons.workspace_premium_rounded;

      case 'private':
        return Icons.lock_outline_rounded;

      case 'public':
        return Icons.public_rounded;

      case 'weekend':
        return Icons.weekend_rounded;

      case 'closed':
        return Icons.lock_clock_outlined;

      default:
        return Icons.info_outline_rounded;
    }
  }

  static String labelForStatus(String rawStatus, String normalizedStatus) {
    if (rawStatus.trim().isEmpty || normalizedStatus == 'null') {
      return '-';
    }
    switch (normalizedStatus) {
      case 'waiting_seen':
      case 'waiting':
        return 'waiting'.tr();
      case 'waiting_cancel':
        return 'waiting_cancel'.tr();
      case 'approved':
        return 'approved'.tr();
      case 'refused':
        return 'refused'.tr();
      case 'rejected':
        return 'rejected'.tr();
      case 'canceled':
      case 'cancelled':
        return 'canceled'.tr();
      case 'seen':
        return 'seen'.tr();
      case 'pending':
        return 'pending'.tr();
      default:
        return rawStatus.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Text and icons use the darkened tone so light colours (orange, yellow) stay readable.
    final tones = AppColors.statusTones(color);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tones.tint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tones.border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: tones.text),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tones.text,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            Icon(trailingIcon, size: iconSize, color: tones.text),
          ],
        ],
      ),
    );
  }
}
