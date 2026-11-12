import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Centred title of every filter sheet (same look as the Requests filter).
class AppFilterTitle extends StatelessWidget {
  final String title;
  const AppFilterTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          title,
          style: AppStyles.heading(context)
              .copyWith(fontWeight: FontWeight.w500, fontSize: 18),
        ),
      );
}

/// The two buttons at the bottom of every filter sheet: Apply Filter (filled pill) at the start
/// and Clear (outlined pill) at the end. One widget so all filters have the same sizes and text.
class AppFilterActions extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onClear;
  const AppFilterActions({super.key, required this.onApply, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onApply,
          child: Container(
            height: AppButtonSize.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(AppColors.buttons),
              borderRadius: AppRadius.button,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s40),
            child: Text(
              AppStrings.applyFilter.tr(),
              style: AppStyles.whiteContent(context)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: Container(
            height: AppButtonSize.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(AppColors.background),
              borderRadius: AppRadius.button,
              border: Border.all(color: Color(AppColors.secondaryButton), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s20),
            child: Text(
              AppStrings.clear.tr(),
              style: AppStyles.darkContent(context)
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

/// The frame of every filter bottom sheet, with the spacing of the Requests filter: handle,
/// title, fields 12 apart, 30 before the buttons and 30 under them. Pass the fields as
/// [children]; the gaps between them are added here.
class AppFilterSheetFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onApply;
  final VoidCallback onClear;
  const AppFilterSheetFrame({
    super.key,
    required this.title,
    required this.children,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(AppColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.s10),
            Container(
              width: 63,
              height: 5,
              decoration: BoxDecoration(
                color: Color(AppColors.disableButton),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSizes.s10),
            Padding(
              padding: const EdgeInsets.all(AppSizes.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFilterTitle(title),
                  const SizedBox(height: AppSpacing.md),
                  for (int i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    children[i],
                  ],
                  const SizedBox(height: AppSizes.s30),
                  AppFilterActions(onApply: onApply, onClear: onClear),
                  const SizedBox(height: AppSizes.s30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
