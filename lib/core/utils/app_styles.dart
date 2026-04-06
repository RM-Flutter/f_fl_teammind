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

  /// White Heading style
  static TextStyle whiteHeading(BuildContext context) {
    return heading(context).copyWith(
      color: Colors.white,
    );
  }

  /// Dark Heading style
  static TextStyle darkHeading(BuildContext context) {
    return heading(context).copyWith(
      color: Color(AppColors.dark),
    );
  }

  /// Black Heading style
  static TextStyle blackHeading(BuildContext context) {
    return heading(context).copyWith(
      color: Colors.black,
    );
  }

  /// Primary Heading style
  static TextStyle primaryHeading(BuildContext context) {
    return heading(context).copyWith(
      color: Color(AppColors.primary),
    );
  }

  /// Grey Heading style
  static TextStyle greyHeading(BuildContext context) {
    return heading(context).copyWith(
      color: Color(AppColors.grey70),
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

  /// Hint Content style
  static TextStyle hintContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.greyA3),
    );
  }

  /// Subtitle Content style
  static TextStyle subtitleContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.darkGrey),
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

  /// Dark Content style
  static TextStyle darkContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.dark),
    );
  }

  /// Almost Black Content style (1B variant)
  static TextStyle almostBlack1BContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.almostBlack1B),
    );
  }

  static TextStyle almostBlackContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.almostBlack),
    );
  }

  /// Dark Blue Content style
  static TextStyle darkBlueContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.darkBlue),
    );
  }

  /// Grey 50 Content style
  static TextStyle grey50Content(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.grey50),
    );
  }

  /// oC2 Content style
  static TextStyle oC2Content(BuildContext context) {
    return content(context).copyWith(
      color: const Color(AppColors.oC2Color),
    );
  }

  /// Grey 52 Content style
  static TextStyle grey52Content(BuildContext context) {
    return content(context).copyWith(
      color: const Color(AppColors.grey52),
    );
  }

  /// Grey 33 Content style
  static TextStyle grey33Content(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.grey33),
    );
  }

  /// Grey 70 Content style
  static TextStyle grey70Content(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.grey70),
    );
  }
}
