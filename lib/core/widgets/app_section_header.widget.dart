import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_design.dart';
import '../constants/app_strings.dart';
import '../utils/app_styles.dart';

/// The title row on top of a section ("My requests ............ View all").
///
/// Same height, font and alignment everywhere: the title starts and "View all" ends exactly on
/// the page edge, so they line up with the cards below (layout rules 1 and 3).
/// It adds no horizontal padding — the section around it pads the page.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  /// Text of the action on the end. Defaults to "View all".
  final String? actionText;

  /// Title colour (e.g. white on a dark section). Defaults to the theme heading colour.
  final Color? color;

  /// Colour of the action text. Defaults to [color] at 80% or the secondary colour.
  final Color? actionColor;

  /// Row height. Defaults to the shared header height; pass a smaller value when the header sits
  /// inside a stack of rows that all use the same 12 gap (e.g. tab content).
  final double height;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.actionText,
    this.color,
    this.actionColor,
    this.height = AppSpacing.sectionHeaderHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActionColor = actionColor ??
        (color != null
            ? color!.withValues(alpha: 0.8)
            : Color(AppColors.secondaryButton));
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.heading(context).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          if (onViewAll != null)
            // Text is centred in the row (never clipped, whatever the row height); the tap area
            // is at least 44 high and may extend past the row.
            SizedBox(
              height: height,
              child: OverflowBox(
                maxHeight: AppSpacing.tapTarget,
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: AppSpacing.tapTarget),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        actionText ?? AppStrings.viewAll.tr(),
                        style: AppStyles.titleTextContent(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: effectiveActionColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
