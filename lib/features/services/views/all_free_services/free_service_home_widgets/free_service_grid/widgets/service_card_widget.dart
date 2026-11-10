import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:flutter/material.dart';

/// One free service: a white card with the service icon on a soft square of its own colour and
/// the name under it. Same card as the rest of the app ([AppCard]), so it follows the theme.
class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showProfileAvatar;
  final String? avatarUrl;
  final Color? backgroundColor;
  final Color? iconColor;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.showProfileAvatar = false,
    this.avatarUrl,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? Color(AppColors.buttons);
    return AppCard(
      animateIn: true,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, size: 22, color: accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.heading(context).copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
