import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Action tile of the Smart Card screens: white [AppCard] with the icon on a soft square of the
/// accent colour (red for destructive actions) and the label under it.
Widget buildActionCard({
  required icon,
  required String label,
  required VoidCallback onTap,
  bool isDestructive = false,
}) {
  final accent = isDestructive ? Colors.red : Color(AppColors.buttons);
  return Builder(
    builder: (context) => SizedBox(
      height: 112,
      child: AppCard(
        animateIn: true,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.heading(context)
                  .copyWith(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25),
            ),
          ],
        ),
      ),
    ),
  );
}
