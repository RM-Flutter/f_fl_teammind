import '../services/dynamic_app_config_service.dart';

abstract class AppColors {

  static int get buttonColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('buttonColor'),
    0xFF3389EE,
  );
  static int get buttonSecondaryColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('buttonSecondaryColor'),
    0xFF3489EF,
  );
  static int get buttonDisabledColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('buttonDisabledColor'),
    0xffB9C0C9,
  );

  // Text Colors
  static int get titleTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('titleTextColor'),
    0xFF090B60,
  );
  static int get bodyTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('bodyTextColor'),
    0xff333333,
  );
  static int get subtitleTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('subtitleTextColor'),
    0xff606060,
  );
  static int get hintTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('hintTextColor'),
    0xFFA3A3A3,
  );
  static int get linkTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('linkTextColor'),
    0xFF3389EE,
  );

  // Background Colors
  static int get backgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('backgroundColor'),
    0xffFFFFFF,
  );
  static int get surfaceF3 => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('surfaceF3'),
    0xFFF3F3F3,
  );
  static int get scaffoldBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('scaffoldBackgroundColor'),
    0xFFF5F8FA,
  );
  static int get cardBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('cardBackgroundColor'),
    0xFFF1F6FF,
  );
  static int get modalBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('modalBackgroundColor'),
    0xffFFFFFF,
  );

  // AppBar Colors
  static int get appBarColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('appBarColor'),
    0xFF3389EE,
  );
  static int get appBarTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('appBarTextColor'),
    0xffFFFFFF,
  );
  static int get appBarIconColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('appBarIconColor'),
    0xffFFFFFF,
  );

  // Border Colors
  static int get borderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('borderColor'),
    0xffE3E5E5,
  );
  static int get dividerColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('dividerColor'),
    0xFFDFDFDF,
  );
  static int get focusedBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('focusedBorderColor'),
    0xFF3389EE,
  );

  // Icon Colors
  static int get iconColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('iconColor'),
    0xFF090B60,
  );
  static int get iconSecondaryColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('iconSecondaryColor'),
    0xff707070,
  );

  // Status Colors
  static int get successColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('successColor'),
    0xff2D6A4F,
  );
  static int get errorColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('errorColor'),
    0xffc72c41,
  );
  static int get warningColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('warningColor'),
    0xffFCA652,
  );
  static int get infoColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('infoColor'),
    0xff3282B8,
  );

  // Input Field Colors
  static int get inputFillColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputFillColor'),
    0xFFF1F6FF,
  );
  static int get inputBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputBorderColor'),
    0xffE3E5E5,
  );
  static int get inputFocusedBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputFocusedBorderColor'),
    0xFF3389EE,
  );
  static int get inputErrorBorderColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('inputErrorBorderColor'),
    0xffc72c41,
  );

  // Shadow & Overlay Colors
  static int get shadowColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('shadowColor'),
    0xff231F20,
  );
  static int get overlayColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('overlayColor'),
    0xff191C1F,
  );

  // Tab & Navigation Colors
  static int get tabActiveColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('tabActiveColor'),
    0xFF3389EE,
  );
  static int get tabInactiveColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('tabInactiveColor'),
    0xff707070,
  );
  static int get navBarColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('navBarColor'),
    0xffFFFFFF,
  );
  static int get navBarActiveColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('navBarActiveColor'),
    0xFF3389EE,
  );

  // Chip & Tag Colors
  static int get chipBackgroundColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('chipBackgroundColor'),
    0xFFF1F6FF,
  );
  static int get chipTextColor => DynamicAppConfigService.hexToInt(
    DynamicAppConfigService.getColorValue('chipTextColor'),
    0xFF090B60,
  );

  // ============================================
  // الألوان القديمة (Legacy Aliases - للتوافق)
  // ============================================

  static const int oC2Color = 0xffAE702B;
  static int get primary => buttonColor;
  static int get blue => buttonSecondaryColor;
  static const int black = 0xff000000;
  static int get blackWithObacity => shadowColor;
  static int get white => backgroundColor;
  static int get dark => titleTextColor;
  static const int realDark = 0xff09051C;
  static const int red = 0xFFBD1316;
  static int get grey50 => dividerColor;
  static int get grey33 => bodyTextColor;
  static const int pink = 0xFFff1493;
  static int get whiteBlue => cardBackgroundColor;
  static int get darkGrey => subtitleTextColor;
  static int get whiteGrey => borderColor;
  static int get lightGrey => buttonDisabledColor;
  static int get almostBlack => overlayColor;
  static const int grey46 = 0xff464646;
  static const int grey3B = 0xFF3B3B3B;
  static int get grey70 => iconSecondaryColor;
  static const int grey4F = 0xff4F4F4F;
  static const int darkBlue = 0xFF011A51;
  static const int grey52 = 0xff525252;
  static int get greyA3 => hintTextColor;
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
  static int get lightBlueBg => scaffoldBackgroundColor;
  static const int almostBlack1B = 0xFF1B1B1B;
  static const int grey51 = 0xFF515151;
  static const int lightGreyEF = 0xFFEFEFEF;
  static const int greyA7 = 0xFFA7A7A7;
  static const int grey67 = 0xFF676D75;
  static const int pinkEE = 0xFFEE3F80;
  static int get helpBlue => infoColor;
  static int get failureRed => errorColor;
  static int get successGreen => successColor;
  static int get warningYellow => warningColor;
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
