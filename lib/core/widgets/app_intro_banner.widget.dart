import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The short description (plain text, no card) + "Learn more about the opportunities →" link that sits on top of the
/// Free Services pages (My CV, Smart Card ...). One widget, so the line looks the same everywhere.
class AppIntroBanner extends StatelessWidget {
  final String description;
  final VoidCallback onLearnMore;
  final String? linkText;
  const AppIntroBanner({
    super.key,
    required this.description,
    required this.onLearnMore,
    this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    // No card around it: the text sits directly on the page.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppStyles.greyContent(context).copyWith(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLearnMore,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    linkText ?? AppStrings.learnMoreAboutOpportunities.tr(),
                    textAlign: TextAlign.center,
                    style: AppStyles.primaryContent(context)
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Flutter mirrors this arrow by itself in RTL.
                Icon(Icons.arrow_forward_rounded, color: accent, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
