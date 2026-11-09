import 'package:flutter/material.dart';

/// Constant sizes to be used in the app (paddings, gaps, rounded corners etc.)
abstract class AppSizes {
  // Employee profile header
  static const double profileHeaderAvatar = 88;
  static const double profileHeaderHeight = 330;

  // More screen
  /// Height of the navy header under the status bar, up to where the white card starts.
  static const double moreHeaderBelowSafeArea = 112;
  static const double moreAvatar = 96;
  static const double moreIconBox = 32;

  // Responsive: widest the page content gets on bigger windows (it is centred)
  static const double contentMaxWidthMedium = 720;
  static const double contentMaxWidthExpanded = 960;
  /// Width of the side navigation rail on expanded windows.
  static const double navRailWidth = 88;

  // Shortcut card (calendar / summary entry above lists)
  static const double shortcutIconBox = 40;

  static const s0 = 0.0;
  static const s1 = 1.0;
  static const s2 = 2.0;
  static const s3 = 3.0;
  static const s4 = 4.0;
  static const s5 = 5.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s13 = 13.0;
  static const s14 = 14.0;
  static const s15 = 14.0;
  static const s16 = 16.0;
  static const s17 = 17.0;
  static const s18 = 18.0;
  static const s19 = 19.0;
  static const s20 = 20.0;
  static const s22 = 22.0;
  static const s24 = 24.0;
  static const s25 = 25.0;
  static const s26 = 26.0;
  static const s28 = 28.0;
  static const s30 = 30.0;
  static const s32 = 32.0;
  static const s36 = 36.0;
  static const s40 = 40.0;
  static const s45 = 45.0;
  static const s48 = 48.0;
  static const s50 = 50.0;
  static const s55 = 55.0;
  static const s60 = 60.0;
  static const s64 = 64.0;
  static const s70 = 70.0;
  static const s72 = 72.0;
  static const s75 = 75.0;
  static const s80 = 80.0;
  static const s88 = 88.0;
  static const s90 = 90.0;
  static const s100 = 100.0;
  static const s110 = 110.0;
  static const s120 = 120.0;
  static const s125 = 125.0;
  static const s140 = 140.0;
  static const s150 = 150.0;
  static const s170 = 170.0;
  static const s180 = 180.0;
  static const s200 = 200.0;
  static const s220 = 220.0;
  static const s240 = 240.0;
  static const s260 = 260.0;
  static const s270 = 270.0;
  static const s290 = 290.0;
  static const s300 = 300.0;
  static const s320 = 320.0;
  static const s340 = 340.0;
  static const s400 = 400.0;
  static const s600 = 600.0;

  // ---------------------------------------------------------------------------
  // Text fields (theme): Figma input height 43 = 13 + ~17 text line + 13.
  // ---------------------------------------------------------------------------
  static const inputHorizontalPadding = 16.0;
  static const inputVerticalPadding = 16.0;

  /// Height of every single-line field and every dropdown (rule 15).
  static const double fieldHeight = 52;

  // ---------------------------------------------------------------------------
  // Figma frame 375 x 812. On phones use these with `.w` / `.h` so the layout
  // keeps the design proportions on every screen.
  // ---------------------------------------------------------------------------
  /// Small pill button (LOGIN, Add Company, ...).
  static const buttonSmallWidth = 149.0;
  static const buttonSmallHeight = 35.0;

  /// Outlined CREATE NEW ACCOUNT pill pinned to the bottom of the login page.
  static const createAccountWidth = 223.0;
  static const createAccountHeight = 38.0;
  static const createAccountBottom = 55.0;

  /// Login page vertical rhythm.
  static const loginContentWidth = 275.0;
  /// Side padding of the login form on phones, widest it gets on tablets / web, and the room
  /// kept under the Saved accounts / language buttons on top.
  static const loginLogoSize = 132.0;
  static const loginSidePadding = 24.0;
  static const loginMaxWidth = 420.0;
  static const loginTopBarClearance = 40.0;
  static const loginTopSpacer = 12.0;
  static const loginLogoTitleGap = 20.0;
  static const loginTitleFormGap = 24.0;
  static const loginSwitchFieldGap = 11.0;
  static const loginFieldGap = 12.0;
  static const loginAfterForgotGap = 26.0;
  static const loginBelowButtonGap = 14.0;
  static const loginForgotFontSize = 11.0;
}

/// Constant gap widths
const gapW4 = SizedBox(width: AppSizes.s4);
const gapW6 = SizedBox(width: AppSizes.s6);
const gapW8 = SizedBox(width: AppSizes.s8);
const gapW10 = SizedBox(width: AppSizes.s10);
const gapW12 = SizedBox(width: AppSizes.s12);
const gapW16 = SizedBox(width: AppSizes.s16);
const gapW20 = SizedBox(width: AppSizes.s20);
const gapW24 = SizedBox(width: AppSizes.s24);
const gapW32 = SizedBox(width: AppSizes.s32);
const gapW48 = SizedBox(width: AppSizes.s48);
const gapW64 = SizedBox(width: AppSizes.s64);

/// Constant gap heights
const gapH2 = SizedBox(height: AppSizes.s2);
const gapH4 = SizedBox(height: AppSizes.s4);
const gapH6 = SizedBox(height: AppSizes.s6);
const gapH8 = SizedBox(height: AppSizes.s8);
const gapH10 = SizedBox(height: AppSizes.s10);
const gapH12 = SizedBox(height: AppSizes.s12);
const gapH14 = SizedBox(height: AppSizes.s14);
const gapH16 = SizedBox(height: AppSizes.s16);
const gapH18 = SizedBox(height: AppSizes.s18);
const gapH20 = SizedBox(height: AppSizes.s20);
const gapH24 = SizedBox(height: AppSizes.s24);
const gapH26 = SizedBox(height: AppSizes.s26);
const gapH28 = SizedBox(height: AppSizes.s28);
const gapH32 = SizedBox(height: AppSizes.s32);
const gapH36 = SizedBox(height: AppSizes.s36);
const gapH48 = SizedBox(height: AppSizes.s48);
const gapH64 = SizedBox(height: AppSizes.s64);
