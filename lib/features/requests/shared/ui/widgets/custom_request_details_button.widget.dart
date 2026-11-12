import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:flutter/material.dart';

class CustomRequestDetailsButton extends StatelessWidget {
  final String title;
  final Color? color;
  final Future<void> Function() onPressed;
  final double? width;

  /// لو true → الـ font بيصغر في الإنجليزي بس (للزراير ذات النص الطويل)
  final bool smallFontOnEnglish;

  const CustomRequestDetailsButton({
    super.key,
    this.width,
    this.color,
    required this.title,
    required this.onPressed,
    this.smallFontOnEnglish = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = LocalizationService.isArabic(context: context);
    final double fontSize =
        smallFontOnEnglish && !isArabic ? 11 : AppButtonSize.fontSize;
    final Color effectiveColor = color ?? Color(AppColors.buttons);

    return Expanded(
      child: CustomElevatedButton(
        width: width ?? double.infinity,
        height: AppButtonSize.compactHeight,
        backgroundColor: effectiveColor,
        buttonStyle: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: effectiveColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
        onPressed: onPressed,
        title: title,
        titleWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: AppStyles.whiteContent(context).copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
