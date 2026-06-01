import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class AppStyles {
  /// Base Heading style (Ibrand for EN / Montserrat-Arabic for AR)
  static TextStyle heading(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Montserrat-Arabic' : 'Ibrand',
      // color: Color(AppColors.secondaryButton),
      color: Colors.black,
      fontSize: isArabic ? 14.sp : 16.sp,
    );
  }

  static TextStyle whiteHeading(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Montserrat-Arabic' : 'Ibrand',
      color: Colors.white,
      fontSize: isArabic ? 14.sp : 16.sp,
    );
  }

  /// Base Content style (Poppins for EN / Cairo for AR)
  static TextStyle content(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      color: const Color(0xff333333),
    );
  }

  /// Grey Content style (often used for hints)
  static TextStyle greyContent(BuildContext context) {
    return content(context).copyWith(
      color: const Color(0xff606060),
    );
  }


  static TextStyle greenContent(BuildContext context) {
    return content(context).copyWith(
      color: Colors.green,
    );
  }

  static TextStyle redContent(BuildContext context) {
    return content(context).copyWith(
      color: Colors.red,
    );
  }

  /// Hint Content style
  static TextStyle hintContent(BuildContext context) {
    return content(context).copyWith(
      color: const Color(0xFFA3A3A3),
    );
  }

  /// Subtitle Content style
  static TextStyle subtitleContent(BuildContext context) {
    return content(context).copyWith(
      color: const Color(0xff606060),
    );
  }

  /// Primary color Content style (often used for links/buttons)
  static TextStyle
  primaryContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.buttons),
    );
  }

  static TextStyle secoundaryContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.secondaryButton),
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
      color: Colors.black,
    );
  }

  /// Almost Black Content style (1B variant)
  static TextStyle almostBlack1BContent(BuildContext context) {
    return content(context).copyWith(
      color: const Color(AppColors.almostBlack1B),
    );
  }

  static TextStyle almostBlackContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.overlay),
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
  
  static TextStyle blackWithObacityContent(BuildContext context) {
    return content(context).copyWith(
      color: Color(AppColors.shadow),
    );
  }

  static TextStyle aboutUsContent(BuildContext context) {
    return content(context).copyWith(
      color: const Color(0xFF333333),
    );
  }

  static TextStyle c1Content(BuildContext context) {
    return content(context).copyWith(
      color: const Color(AppColors.c1),
    );
  }






  static TextStyle titleTextContent(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      color: Colors.black,
    );
  }

  static TextStyle bodyTextContent(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      color: const Color(0xff333333),
    );
  }

  static TextStyle subTitleContent(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      color: const Color(0xff606060),
    );
  }

  static TextStyle hintTitleContent(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    return TextStyle(
      fontFamily: isArabic ? 'Cairo' : 'Poppins',
      color: const Color(0xFFA3A3A3),
    );
  }

}
