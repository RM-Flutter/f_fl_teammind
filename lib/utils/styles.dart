import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../constants/app_colors.dart';

class TextsStyles{
  static var htmlStyle = {
    "h1":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(26),
      fontWeight: FontWeight.w700,
    ),"h2":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(24),
      fontWeight: FontWeight.w700,
    ),"h3":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(22),
      fontWeight: FontWeight.w700,
    ),"h4":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(20),
      fontWeight: FontWeight.w700,
    ),"h5":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"h6":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(16),
      fontWeight: FontWeight.w700,
    ),
    "p": Style(
      color: Color(AppColors.grey52),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(14), // Adjust font size for better visibility
      fontWeight: FontWeight.w400,
    ), "ul": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"li": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"ol": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),
  };
  static var htmlStyles = {
    "h1":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(26),
      fontWeight: FontWeight.w700,
    ),"h2":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(24),
      fontWeight: FontWeight.w700,
    ),"h3":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(22),
      fontWeight: FontWeight.w700,
    ),"h4":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(20),
      fontWeight: FontWeight.w700,
    ),"h5":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"h6":Style(
      color: Color(AppColors.dark),
      fontSize: FontSize(16),
      fontWeight: FontWeight.w700,
    ),
    "p": Style(
      color: Color(AppColors.white),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(14), // Adjust font size for better visibility
      fontWeight: FontWeight.w400,
    ), "ul": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"li": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),"ol": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18), // Adjust font size for better visibility
      fontWeight: FontWeight.w700,
    ),
  };

  // Variant specifically for About App screen: headings in primary color
  static var htmlStylesAbout = {
    "h1":Style(
      color: Color(AppColors.primary),
      fontSize: FontSize(26),
      fontWeight: FontWeight.w700,
    ),"h2":Style(
      color: Color(AppColors.primary),
      fontSize: FontSize(24),
      fontWeight: FontWeight.w700,
    ),"h3":Style(
      color: Color(AppColors.primary),
      fontSize: FontSize(22),
      fontWeight: FontWeight.w700,
    ),"h4":Style(
      color: Color(AppColors.primary),
      fontSize: FontSize(20),
      fontWeight: FontWeight.w700,
    ),"h5":Style(
      color: Color(AppColors.primary),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"h6":Style(
      color: Color(AppColors.primary),
      fontSize: FontSize(16),
      fontWeight: FontWeight.w700,
    ),
    "p": Style(
      color: Color(AppColors.white),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(14),
      fontWeight: FontWeight.w400,
    ), "ul": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"li": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),"ol": Style(
      color: Color(AppColors.grey33),
      lineHeight: LineHeight(1.5),
      fontSize: FontSize(18),
      fontWeight: FontWeight.w700,
    ),
  };
}