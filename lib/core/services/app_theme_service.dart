import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/models/color_palette.model.dart';
import 'package:app_test/core/models/color_value.model.dart';
import 'localization_service.dart';
import 'package:app_test/core/constants/app_design.dart';

abstract class AppThemeService {
  static final ColorPalette colorPalette = ColorPalette(
    name: 'Main Theme',
    // application primary colors
    primaryColor: ColorValue(light: Color(AppColors.buttons), dark: Color(AppColors.buttons)),

    secondaryColor: ColorValue(light: Color(AppColors.secondaryButton), dark: Color(AppColors.secondaryButton)),
    tertiaryColor: ColorValue(light: const Color(AppColors.black), dark: const Color(AppColors.black)),
    // application background colors
    primaryColorBackground: ColorValue(light: Color(AppColors.secondaryButton), dark: Color(AppColors.secondaryButton)),
    secondaryColorBackground: ColorValue(light: const Color(AppColors.pink), dark: const Color(AppColors.pink)),
    tertiaryColorBackground: ColorValue(light: Color(AppColors.background), dark: Color(AppColors.background)),
    // application texts colors
    primaryTextColor: ColorValue(light: Color(AppColors.secondaryButton), dark: Color(AppColors.secondaryButton)),
    secondaryTextColor: ColorValue(light: Color(AppColors.secondaryButton), dark: Color(AppColors.secondaryButton)),
    tertiaryTextColor: ColorValue(light: const Color(AppColors.black), dark: const Color(AppColors.black)),
    quaternaryTextColor: ColorValue(
        light: Color(0xff606060),
        dark: Color(0xff606060)),
    quinaryTextColor: ColorValue(
        light: Color(AppColors.background),
        dark: Color(AppColors.background)),
    //scaffold colors
    appBarBackgroundColor: ColorValue(
        light: const Color(AppColors.black),
        dark: const Color(AppColors.black)),
    bodyBackgroundColor: ColorValue(
        light: Color(AppColors.background),
        dark: Color(AppColors.background)),
    btmAppBarBackgroundColor: ColorValue(
        light: Color(AppColors.background),
        dark: Color(AppColors.background)),
    fabBackgroundColor: ColorValue(
        light: const Color(AppColors.pink),
        dark: const Color(AppColors.pink)),
    fabIconColor: ColorValue(
        light: Color(AppColors.background),
        dark: Color(AppColors.background)),
    // input colors
    inputBorderColor: ColorValue(
        light: Color(AppColors.divider),
        dark: Color(AppColors.divider)),
    inputFillColor: ColorValue(
        light: Color(AppColors.background),
        dark: Color(AppColors.background)),
    inputHintColor: ColorValue(
        light: Color(AppColors.shadow),
        dark: Color(AppColors.shadow)),
    inputLabelColor: ColorValue(
        light: Color(AppColors.divider),
        dark: Color(AppColors.divider)),
    inputTextColor: ColorValue(
        light: Color(AppColors.shadow),
        dark: Color(AppColors.shadow)),
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
            color: Colors.white),
        headlineMedium: TextStyle(
          // --> used
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.s13),
        headlineSmall: TextStyle(
          // --> used
            fontWeight: FontWeight.w600,
            color: colorPalette.quinaryTextColor.color,
            fontSize: AppSizes.s16),
        headlineLarge: TextStyle(
          // --> used for the title of modal sheet
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.s20,
            color: Color(AppColors.secondaryButton)),
        bodySmall: TextStyle(
          // --> used
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.s10,
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
            ? AppConstants.fontFamilyCairo
            : AppConstants.fontFamilyPoppins,
        hoverColor: AppField.hoverColor,
        // application input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          hoverColor: AppField.hoverColor,
          // Hint, end icon and size are the same for every field (rule 15, AppField).
          hintStyle: AppField.hintStyle,
          suffixIconColor: AppField.iconColor,
          prefixIconColor: AppField.iconColor,
          suffixIconConstraints: const BoxConstraints(minWidth: 54, minHeight: AppField.height),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(
                color: colorPalette.inputBorderColor.color, width: AppSizes.s1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: Color(AppColors.buttons), width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(
                color: colorPalette.inputBorderColor.color, width: AppSizes.s1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: Color(AppColors.failureRed), width: AppSizes.s1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide(color: Color(AppColors.failureRed), width: 1.5),
          ),
          labelStyle: TextStyle(
            color: colorPalette.inputLabelColor.color,
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.s12,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.inputHorizontalPadding,
            vertical: AppSizes.inputVerticalPadding,
          ),
          fillColor: colorPalette.inputFillColor.color,
          isDense: true,
        ),
        // Cards: white, 12px corners, 12% grey border, soft 3% shadow (see AppCard / app_design.dart)
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: const Color(0x1F101828),
          elevation: AppElevation.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: AppBorders.cardSide,
          ),
          clipBehavior: Clip.antiAlias,
        ),
        dividerTheme: DividerThemeData(color: Color(AppColors.divider), thickness: 1, space: 1),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          side: BorderSide.none,
          backgroundColor: Color(AppColors.chipBackground),
          labelStyle: TextStyle(color: Color(AppColors.chipText), fontSize: 12.5, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Color(AppColors.modalBackground),
          surfaceTintColor: Colors.transparent,
          elevation: AppElevation.overlay,
          shadowColor: const Color(0x29101828),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Color(AppColors.modalBackground),
          surfaceTintColor: Colors.transparent,
          constraints: const BoxConstraints(maxWidth: 600),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
        ),
        // application fab theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorPalette.fabBackgroundColor.color,
          elevation: AppElevation.raised,
          shape: const CircleBorder(),
        ),
        // application appbar theme (unified white bar + navy title)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: AppSizes.s0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(AppColors.secondaryButton)),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.secondaryButton),
            fontFamily: LocalizationService.isArabic(context: context)
                ? AppConstants.fontFamilyCairo
                : AppConstants.fontFamilyPoppins,
          ),
        ),
        // application text theme
        textTheme: _textTheme(context: context, isDark: isDark).apply(
          fontFamily: LocalizationService.isArabic(context: context)
              ? AppConstants.fontFamilyCairo
              : AppConstants.fontFamilyPoppins,
        ),
        // application theme
        brightness: isDark ? Brightness.dark : Brightness.light,
        // application btm nav bar theme
        bottomAppBarTheme: BottomAppBarThemeData(
          color: colorPalette.btmAppBarBackgroundColor.color,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: isDark ? Brightness.dark : Brightness.light,
          secondary: colorPalette.secondaryColor.get(isDark),
          seedColor: colorPalette.primaryColor.get(isDark),
          primary: colorPalette.primaryColor.get(isDark),
        ),
        // Buttons: all pill shaped, same height, padding and text (see AppButtonSize)
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(AppColors.buttons),
              elevation: 0,
              minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.height),
              padding: AppButtonSize.padding,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              textStyle: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600),
            )),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(AppColors.buttons),
              minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.height),
              padding: AppButtonSize.padding,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              textStyle: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600),
            )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(AppColors.buttons),
              side: BorderSide(color: Color(AppColors.buttons), width: 1.5),
              minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.height),
              padding: AppButtonSize.padding,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              textStyle: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600),
            )),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(AppColors.buttons),
              minimumSize: const Size(AppButtonSize.minWidth, AppButtonSize.compactHeight),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              textStyle: const TextStyle(fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600),
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
                ? AppConstants.fontFamilyCairo
                : AppConstants.fontFamilyPoppins,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelColor: colorPalette.tertiaryTextColor.color,
          unselectedLabelStyle: TextStyle(
              fontSize: AppSizes.s16,
              fontFamily: LocalizationService.isArabic(context: context)
                  ? AppConstants.fontFamilyCairo
                  : AppConstants.fontFamilyPoppins,
              fontWeight: FontWeight.w500),
          labelPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),

        popupMenuTheme: PopupMenuThemeData(
          color: colorPalette.tertiaryColorBackground.color,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          elevation: AppSizes.s8,
        ),
      );
}
