import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../constants/app_colors.dart';

class TextsStyles{
  static var htmlStyle = {
    "h1":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(26),
      fontWeight: FontWeight.w700,
    ),"h2":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(24),
      fontWeight: FontWeight.w700,
    ),"h3":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(22),
      fontWeight: FontWeight.w700,
    ),"h4":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(20),
      fontWeight: FontWeight.w700,
    ),"h5":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"h6":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(16),
      fontWeight: FontWeight.w700,
    ),
    "p": Style(
      color: const Color(AppColors.grey52),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(14), // Adjust font size for better visibility
      fontWeight: FontWeight.w400,
    ), "ul": Style(
      color: Color(AppColors.bodyText),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"li": Style(
      color: Color(AppColors.bodyText),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"ol": Style(
      color: Color(AppColors.bodyText),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),
  };
  static var htmlStyles = {
    "h1":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(26),
      fontWeight: FontWeight.w700,
    ),"h2":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(24),
      fontWeight: FontWeight.w700,
    ),"h3":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(22),
      fontWeight: FontWeight.w700,
    ),"h4":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(20),
      fontWeight: FontWeight.w700,
    ),"h5":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"h6":Style(
      color: Color(AppColors.titleText),
      fontSize: FontSize(16),
      fontWeight: FontWeight.w700,
    ),
    "p": Style(
      color: Color(AppColors.background),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(14), // Adjust font size for better visibility
      fontWeight: FontWeight.w400,
    ), "ul": Style(
      color: Color(AppColors.bodyText),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"li": Style(
      color: Color(AppColors.bodyText),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"ol": Style(
      color: Color(AppColors.bodyText),
      lineHeight: const LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),
  };

  // Variant specifically for About App screen: headings in primary color
}
