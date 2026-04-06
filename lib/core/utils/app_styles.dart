import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';

class AppStyles {
  /// Base Heading style (Ibrand for EN / Montserrat-Arabic for AR)
  static TextStyle heading(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Montserrat-Arabic' : 'Ibrand',
      color: Color(AppColors.titleTextColor),
    );
  }

  /// Base Content style (Poppins for EN / Cairo for AR)
  static TextStyle content(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      color: Color(AppColors.bodyTextColor),
    );
  }

  /// Grey Content style (often used for hints)
  static TextStyle greyContent(BuildContext context) {
    return content(context).copyWith(
      color: const Color(0xff606060),
    );
  }

  /// Primary color Content style (often used for links/buttons)
  static TextStyle primaryContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.primary),
    );
  }

  /// White Content style (often used for toasts/messages)
  static TextStyle whiteContent(BuildContext context) {
    return content(context).copyWith(
      color: Colors.white,
    );
  }

  /// Black Content style (often used for toasts/messages)
  static TextStyle blackContent(BuildContext context) {
    return content(context).copyWith(
      color: Colors.black,
    );
  }
}
