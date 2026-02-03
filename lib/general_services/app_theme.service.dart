import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_sizes.dart';
import '../models/color_palette.model.dart';
import '../models/color_value.model.dart';
import 'localization.service.dart';

abstract class AppThemeService {
  static final ColorPalette colorPalette = ColorPalette(
    name: 'Main Theme',
    // application primary colors
    primaryColor: ColorValue(
        light: Color(AppColors.primary), dark: Color(AppColors.primary)),
    secondaryColor: ColorValue(
        light: Color(AppColors.dark), dark: Color(AppColors.dark)),
    tertiaryColor: ColorValue(
        light: const Color(AppColors.black), dark: const Color(AppColors.black)),
    // application background colors
    primaryColorBackground: ColorValue(
        light: Color(AppColors.dark), dark: Color(AppColors.dark)),
    secondaryColorBackground: ColorValue(
        light: const Color(AppColors.pink), dark: const Color(AppColors.pink)),
    tertiaryColorBackground: ColorValue(
        light: Color(AppColors.white), dark: Color(AppColors.white)),
    // application texts colors
    primaryTextColor: ColorValue(
        light: Color(AppColors.dark),
        dark: Color(AppColors.dark)),
    secondaryTextColor: ColorValue(
        light: Color(AppColors.dark),
        dark: Color(AppColors.dark)),
    tertiaryTextColor: ColorValue(
        light: const Color(AppColors.black),
        dark: const Color(AppColors.black)),
    quaternaryTextColor: ColorValue(
        light: Color(AppColors.darkGrey),
        dark: Color(AppColors.darkGrey)),
    quinaryTextColor: ColorValue(
        light: Color(AppColors.white),
        dark: Color(AppColors.white)),
    //scaffold colors
    appBarBackgroundColor: ColorValue(
        light: const Color(AppColors.black),
        dark: const Color(AppColors.black)),
    bodyBackgroundColor: ColorValue(
        light: Color(AppColors.white),
        dark: Color(AppColors.white)),
    btmAppBarBackgroundColor: ColorValue(
        light: Color(AppColors.white),
        dark: Color(AppColors.white)),
    fabBackgroundColor: ColorValue(
        light: const Color(AppColors.pink),
        dark: const Color(AppColors.pink)),
    fabIconColor: ColorValue(
        light: Color(AppColors.white),
        dark: Color(AppColors.white)),
    // input colors
    inputBorderColor: ColorValue(
        light: Color(AppColors.grey50),
        dark: Color(AppColors.grey50)),
    inputFillColor: ColorValue(
        light: Color(AppColors.white),
        dark: Color(AppColors.white)),
    inputHintColor: ColorValue(
        light: Color(AppColors.blackWithObacity),
        dark: Color(AppColors.blackWithObacity)),
    inputLabelColor: ColorValue(
        light: Color(AppColors.grey50),
        dark: Color(AppColors.grey50)),
    inputTextColor: ColorValue(
        light: Color(AppColors.blackWithObacity),
        dark: Color(AppColors.blackWithObacity)),
  );
  static TextTheme _textTheme(
          {required bool isDark, required BuildContext context}) =>
      TextTheme(
        displayLarge: TextStyle(
          // --> used
          fontSize: AppSizes.s22,
          fontWeight: FontWeight.w600,
          color: colorPalette.secondaryTextColor.get(isDark),
        ),
        displayMedium: TextStyle(
            // --> used
            letterSpacing: LocalizationService.isArabic(context: context)
                ? null
                : AppSizes.s12,
            height: AppSizes.s6,
            fontSize: AppSizes.s16,
            fontWeight: FontWeight.w500,
            color: Colors.white),
        displaySmall: TextStyle(
          // --> used
          fontSize: AppSizes.s14,
          fontWeight: FontWeight.w400,
          color: colorPalette.quaternaryTextColor.get(isDark),
        ),
        labelLarge: TextStyle(
            // --> used
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.s24,
            color: Colors.white,
            // تحسين الخطوط في الويب
            letterSpacing: kIsWeb && !LocalizationService.isArabic(context: context) ? 0.3 : null),
        headlineMedium: TextStyle(
            // --> used
            letterSpacing:
                LocalizationService.isArabic(context: context) ? null : 1.2,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.s13),
        headlineSmall: TextStyle(
            // --> used
            fontWeight: FontWeight.w600,
            color: colorPalette.quinaryTextColor.color,
            fontSize: AppSizes.s16,
            letterSpacing:
                LocalizationService.isArabic(context: context) ? null : 1.6),
        headlineLarge: TextStyle(
            // --> used for the title of modal sheet
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.s20,
            color: Color(AppColors.dark),
            // تحسين الخطوط في الويب
            letterSpacing: kIsWeb && !LocalizationService.isArabic(context: context) ? 0.5 : null),
        bodySmall: TextStyle(
          // --> used
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.s10,
          letterSpacing:
              LocalizationService.isArabic(context: context) ? null : 1,
          color: const Color(AppColors.grey47),
        ),
        bodyMedium: TextStyle(
          // -> used
          fontSize: AppSizes.s14,
          fontWeight: FontWeight.w500,
          color: colorPalette.secondaryTextColor.get(isDark),
        ),
        bodyLarge: TextStyle(
            // -> used for style of the input text
            color: colorPalette.inputTextColor.color),
        labelSmall: TextStyle(
          //-> used
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.s12,
          letterSpacing:
              LocalizationService.isArabic(context: context) ? null : 0.5,
          color: const Color(AppColors.grey3B),
        ),
        titleLarge: const TextStyle(
          // --> used
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.s14,
          color: Colors.white,
        ),
        titleSmall: const TextStyle(
          //--> used
          fontWeight: FontWeight.normal,
          fontSize: AppSizes.s12,
          height: 1.0,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          //-- >used
          fontSize: AppSizes.s14,
          fontWeight: FontWeight.w500,
          letterSpacing:
              LocalizationService.isArabic(context: context) ? null : 0.75,
          height: 1.1,
          color: colorPalette.primaryTextColor.get(isDark).withOpacity(.75),
        ),
        titleMedium: const TextStyle(
          fontSize: AppSizes.s17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );

  static ThemeData getTheme(
          {required bool isDark, required BuildContext context}) =>
      ThemeData(
        // application font family
        fontFamily: LocalizationService.isArabic(context: context)
            ? AppConstants.fontFamilyMontserratArabic
            : AppConstants.fontFamilyIbrand,
        // application input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
              color: colorPalette.inputHintColor.color,
              fontWeight: FontWeight.w500,
              fontSize: AppSizes.s12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s15),
            borderSide: BorderSide(
                color: colorPalette.inputBorderColor.color, width: AppSizes.s1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s15),
            borderSide: BorderSide(
                color: colorPalette.inputBorderColor.color, width: AppSizes.s1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.s15),
            borderSide: BorderSide(
                color: colorPalette.inputBorderColor.color, width: AppSizes.s1),
          ),
          labelStyle: TextStyle(
            color: colorPalette.inputLabelColor.color,
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.s12,
          ),
          filled: true,
          contentPadding: const EdgeInsets.all(AppSizes.s20),
          fillColor: colorPalette.inputFillColor.color,
          isDense: true,
        ),
        //application card theme
        cardTheme: CardThemeData(color: colorPalette.tertiaryColorBackground.color),
        // application fab theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorPalette.fabBackgroundColor.color,
          shape: const CircleBorder(),
        ),
        // application appbar theme
        appBarTheme: AppBarTheme(
          backgroundColor: colorPalette.appBarBackgroundColor.color,
          elevation: AppSizes.s0,
          centerTitle: true,
        ),
        // application text theme
        textTheme: _textTheme(context: context, isDark: isDark).apply(
          fontFamily: LocalizationService.isArabic(context: context)
              ? AppConstants.fontFamilyMontserratArabic
              : AppConstants.fontFamilyIbrand,
        ),
        // application theme
        brightness: isDark ? Brightness.dark : Brightness.light,
        // application btm nav bar theme
        bottomAppBarTheme: BottomAppBarTheme(
          color: colorPalette.btmAppBarBackgroundColor.color,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: isDark ? Brightness.dark : Brightness.light,
          secondary: colorPalette.secondaryColor.get(isDark),
          seedColor: colorPalette.primaryColor.get(isDark),
          primary: colorPalette.primaryColor.get(isDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          foregroundColor: colorPalette.quinaryTextColor.color,
          backgroundColor: colorPalette.primaryColorBackground.color,
        )),
        textButtonTheme: TextButtonThemeData(
            style: ElevatedButton.styleFrom(
          fixedSize: const Size(double.infinity, double.infinity),
          backgroundColor: Colors.transparent,
          foregroundColor: colorPalette.secondaryColor.color,
          elevation: 0,
        )),

        tabBarTheme: TabBarThemeData(
          dividerHeight: 0,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 0, color: Colors.transparent),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(
            fontSize: AppSizes.s16,
            fontFamily: LocalizationService.isArabic(context: context)
                ? AppConstants.fontFamilyMontserratArabic
                : AppConstants.fontFamilyIbrand,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelColor: colorPalette.tertiaryTextColor.color,
          unselectedLabelStyle: TextStyle(
              fontSize: AppSizes.s16,
              fontFamily: LocalizationService.isArabic(context: context)
                  ? AppConstants.fontFamilyMontserratArabic
                  : AppConstants.fontFamilyIbrand,
              fontWeight: FontWeight.bold),
          labelPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),

        popupMenuTheme: PopupMenuThemeData(
          color: colorPalette.tertiaryColorBackground.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.s12),
          ),
          elevation: AppSizes.s8,
        ),
      );
}
