import 'package:flutter/painting.dart';

import '../services/dynamic_app_config_service.dart';

/// The four shades a status colour is drawn with, so a light colour (orange, yellow, light blue)
/// is still readable as text and calm as a background. Built from ANY base colour, including
/// ones that come from the server. See [AppColors.statusTones].
class StatusTones {
  /// Text and small icons: darkened until it reaches 4.5:1 on [tint].
  final Color text;

  /// Ring / outline of avatars and icon circles.
  final Color ring;

  /// Thin borders of badges.
  final Color border;

  /// Soft background of badges and avatars.
  final Color tint;
  const StatusTones(
      {required this.text,
      required this.ring,
      required this.border,
      required this.tint});
}

abstract class AppColors {
  static final Map<int, StatusTones> _toneCache = {};

  /// Splits one status colour into [StatusTones] (HSL based, so it also works for colours the
  /// company picks on the server). Use this instead of drawing text/borders in the raw colour.
  static StatusTones statusTones(Color base) {
    return _toneCache.putIfAbsent(base.toARGB32(), () {
      final hsl = HSLColor.fromColor(base);
      // Greys (no hue) keep their saturation at 0.
      final sat = hsl.saturation;
      final tint = hsl
          .withSaturation((sat * 0.9).clamp(0.0, 0.9))
          .withLightness(0.95)
          .toColor();
      final border = hsl
          .withSaturation((sat * 0.8).clamp(0.0, 0.8))
          .withLightness(0.82)
          .toColor();
      final ring = hsl
          .withSaturation((sat * 0.85).clamp(0.0, 1.0))
          .withLightness(hsl.lightness.clamp(0.0, 0.58))
          .toColor();
      // Darken the text step by step until it is readable on the tint (4.5:1).
      var l = hsl.lightness.clamp(0.0, 0.42);
      var text = hsl.withLightness(l).toColor();
      while (_contrast(text, tint) < 4.5 && l > 0.12) {
        l -= 0.02;
        text = hsl.withLightness(l).toColor();
      }
      return StatusTones(text: text, ring: ring, border: border, tint: tint);
    });
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  static int get buttonColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('secondary'),
        0xFF3389EE,
      );

  static int get buttonSecondaryColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('primary'),
        0xFF090B60,
      );

  static int get buttonDisabledColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('buttonDisabledColor'),
        0xffB9C0C9,
      );


  // Text Colors
  static int get titleTextColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('titleTextColor'),
        0xFF090B60,
      );

  static int get bodyTextColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('bodyTextColor'),
        0xff333333,
      );

  static int get subtitleTextColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('subtitleTextColor'),
        0xff606060,
      );

  static int get hintTextColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('hintTextColor'),
        0xFFA3A3A3,
      );

  // static int get linkTextColor => DynamicAppConfigService.hexToInt(
  //   DynamicAppConfigService.getColorValue('linkTextColor'),
  //   0xFF3389EE,
  // );

  // Background Colors
  static int get backgroundColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('backgroundColor'),
        0xffFFFFFF,
      );

  static int get scaffoldBackgroundColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('scaffoldBackgroundColor'),
        0xFFF5F8FA,
      );

  static int get cardBackgroundColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('cardBackgroundColor'),
        0xFFF1F6FF,
      );

  static int get modalBackgroundColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('modalBackgroundColor'),
        0xffFFFFFF,
      );


  // AppBar Colors
  static int get appBarColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('appBarColor'),
        0xFF3389EE,
      );

  static int get appBarTextColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('appBarTextColor'),
        0xffFFFFFF,
      );

  static int get appBarIconColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('appBarIconColor'),
        0xffFFFFFF,
      );


  // Border Colors
  static int get borderColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('borderColor'),
        0xffE3E5E5,
      );

  static int get dividerColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('dividerColor'),
        0xFFDFDFDF,
      );

  static int get focusedBorderColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('focusedBorderColor'),
        0xFF3389EE,
      );

  // Icon Colors
  static int get iconColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('iconColor'),
        0xFF090B60,
      );

  static int get iconSecondaryColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('iconSecondaryColor'),
        0xff707070,
      );

  // Status Colors
  static int get successColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('successColor'),
        0xff2D6A4F,
      );

  static int get errorColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('errorColor'),
        0xffc72c41,
      );

  static int get warningColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('warningColor'),
        0xffF0A04B,
      );

  static int get infoColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('infoColor'),
        0xff3282B8,
      );


  // Input Field Colors
  static int get inputFillColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('inputFillColor'),
        0xFFF1F6FF,
      );

  static int get inputBorderColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('inputBorderColor'),
        0xffE3E5E5,
      );

  static int get inputFocusedBorderColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('inputFocusedBorderColor'),
        0xFF3389EE,
      );

  static int get inputErrorBorderColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('inputErrorBorderColor'),
        0xffc72c41,
      );

  // Shadow & Overlay Colors
  static int get shadowColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('shadowColor'),
        0xff231F20,
      );

  static int get overlayColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('overlayColor'),
        0xff191C1F,
      );

  /// Colour the background photo fades into at the bottom of a page (login,
  /// splash). The company's `overlayColor` when configured, otherwise the
  /// Figma navy.
  static int get fadeColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('overlayColor'),
        0xff09075E,
      );

  // Tab & Navigation Colors
  static int get tabActiveColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('tabActiveColor'),
        0xFF3389EE,
      );

  static int get tabInactiveColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('tabInactiveColor'),
        0xff707070,
      );

  static int get navBarColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('navBarColor'),
        0xffFFFFFF,
      );

  static int get navBarActiveColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('navBarActiveColor'),
        0xFF3389EE,
      );

  // Chip & Tag Colors
  static int get chipBackgroundColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('chipBackgroundColor'),
        0xFFF1F6FF,
      );

  static int get chipTextColor =>
      DynamicAppConfigService.hexToInt(
        DynamicAppConfigService.getColorValue('chipTextColor'),
        0xFF090B60,
      );

  // ============================================
  // Used Color in features
  // ============================================

  static const int oC2Color = 0xffAE702B;

  // ألوان شعار تيم مايند، تُستخدم لرسم شخصية "Mr. TeamMind" في المساعد.
  static const int brandNavy = 0xFF080A5F;
  static const int brandBlue = 0xFF3489EF;

  // Buttons
  static int get buttons => buttonColor;

  static int get secondaryButton => buttonSecondaryColor;

  static int get disableButton => buttonDisabledColor;


  // Texts
  static int get titleText => titleTextColor;

  static int get bodyText => bodyTextColor;

  static int get subTitleText => subtitleTextColor;

  static int get hintText => hintTextColor;

  // Background
  static int get background => backgroundColor;

  static int get scaffoldBackGround => scaffoldBackgroundColor;

  static int get cardBackground => cardBackgroundColor;

  static int get modalBackground => modalBackgroundColor;

  // Appbar
  static int get appBar => appBarColor;

  static int get appBarText => appBarTextColor;

  static int get appBarIcon => appBarIconColor;


  // Borders
  static int get border => borderColor;

  static int get divider => dividerColor;

  static int get focusedBorder => focusedBorderColor;


  // icons
  static int get icon => iconColor;

  static int get iconSecondary => iconSecondaryColor;

  // status
  static int get successGreen => successColor;

  static int get warningYellow => warningColor;

  static int get failureRed => errorColor;

  static int get helpBlue => infoColor;

  // input fields
  static int get inputFill => inputFillColor;

  static int get inputBorder => inputBorderColor;

  static int get inputFocusedBorder => inputFocusedBorderColor;

  static int get inputErrorBorder => inputErrorBorderColor;

  // shadows
  static int get shadow => shadowColor;

  static int get overlay => overlayColor;

  // taps
  static int get tabActive => tabActiveColor;

  static int get tabInactive => tabInactiveColor;

  static int get navBar => navBarColor;

  static int get navBarActive => navBarActiveColor;

  // Chips
  static int get chipBackground => chipBackgroundColor;

  static int get chipText => chipTextColor;


  // normal colors (here not come from back-end, static colors)
  static const int black = 0xff000000;
  static const int realDark = 0xff09051C;
  static const int red = 0xFFBD1316;
  static const int pink = 0xFFff1493;
  static const int grey46 = 0xff464646;
  static const int grey3B = 0xFF3B3B3B;
  static const int grey4F = 0xff4F4F4F;
  static const int darkBlue = 0xFF011A51;
  static const int grey52 = 0xff525252;
  static const int pureRed = 0xffFF0000;
  static const int darkBlueGrey = 0xff31394D;
  static const int green = 0xff09814D;
  static const int veryDarkBlue = 0xff0D3B6F;
  static const int darkRed = 0xff851919;
  static const int navyBlue = 0xff2C376C;
  static const int lightGreyE5 = 0xffE5E5E5;
  static const int grey47 = 0xFF474747;
  static const int grey40 = 0xff404040;
  static const int pinkLight = 0xFFFF007A;
  static const int blueLight = 0xFF00A1FF;
  static const int almostBlack1B = 0xFF1B1B1B;
  static const int grey51 = 0xFF515151;
  static const int lightGreyEF = 0xFFEFEFEF;
  static const int greyA7 = 0xFFA7A7A7;
  static const int grey67 = 0xFF676D75;
  static const int pinkEE = 0xFFEE3F80;

  static const int lightBlue = 0xff3AC0E5;
  static const int purple = 0xff9C4995;

  static const int oc1 = 0xFF0D3B6F;
  static const int oc2 = 0xFFE6007E;
  static const int oc3 = 0xFFFEED00;
  static const int black1 = 0xFF1B1B1B;
  static const int red1 = 0xFFFF6B6B;
  static const int gray1 = 0xFF464646;

  // application colors
  static const int c1 = 0xff1E2D74;
  static const int c2 = 0xffff1493;
  static const int c3 = 0xFF000000;

// application background colors
  static const int bgC1 = 0xff1E2D74;
  static const int bgC2 = 0xffff1493;
  static const int bgC3 = 0xFFFFFFFF;

// application text colors
  static const int textC1 = 0xff1E2D74;
  static const int textC2 = 0xffff1493;
  static const int textC3 = 0xFF000000;
  static const int textC4 = 0xff606060;
  static const int textC5 = 0xFFFFFFFF;

//scaffold colors
  static const int appBarBackgroundColor = 0x00000000; // transparent
  static const int bodyBackgroundColor = 0xFFFFFFFF;
  static const int btmAppBarBackgroundColor = 0xFFFFFFFF;
  static const int fabBackgroundColor = 0xffff1493;
  static const int fabIconColor = 0xFFFFFFFF;

// input colors
  static const int inputHintColor = 0xff231F20;
  static const int inputLabelColor = 0xffDFDFDF;
  static const int inputTextColor = 0xff231F20;

  //grideview background color
  static const int oC1Color = 0xff0D3B6F;
  static const int yellowColor = 0xffEFDF00;
  static const int grey1Color = 0xff4A4A4A;
  static const int black1Color = 0xff1B1B1B;
  static const int red1Color = 0xffA60B0B;
}
