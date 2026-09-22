import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/services/localization_service.dart';

class CustomRequestDetailsButton extends StatelessWidget {
  final String title;
  var color;
  final Future<void> Function() onPressed;
  final double? width;
  /// لو true → الـ font بيصغر في الإنجليزي بس (للزراير ذات النص الطويل)
  final bool smallFontOnEnglish;

  CustomRequestDetailsButton({
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
    final double fontSize = smallFontOnEnglish && !isArabic ? 9 : 11;
    return Expanded(
      child: CustomElevatedButton(
        titleSize: 10,
        width: width,
        buttonStyle: ElevatedButton.styleFrom(
          fixedSize: const Size(double.infinity, double.infinity),alignment: Alignment.center,
          shadowColor: Colors.transparent,
          backgroundColor:color?? Color(AppColors.secondaryButton),
          foregroundColor: color??Color(AppColors.secondaryButton),
          disabledForegroundColor: Colors.transparent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
        title: title,
        titleWidget: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title.toUpperCase(),
            style: AppStyles.whiteContent(context).copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}