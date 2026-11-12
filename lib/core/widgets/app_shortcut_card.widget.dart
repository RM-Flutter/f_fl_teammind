import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

/// A light "go to" row that sits on top of a list (e.g. "Team calendar", "Report summary").
/// Replaces the full-width blue pill button so the list stays the main thing on the page.
/// Icon in a soft square, title + optional hint, and an arrow that follows the text direction.
class AppShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const AppShortcutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: AppSizes.shortcutIconBox,
            height: AppSizes.shortcutIconBox,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.heading(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            // Flutter mirrors this icon by itself in RTL; flipping it by hand flips it twice.
            Icons.chevron_right_rounded,
            color: accent,
            size: 22,
          ),
        ],
      ),
    );
  }
}
