import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/platform/platform_is.dart';

/// The three window sizes the whole app is built for (same split as Material 3 window size
/// classes). Decide layout from the WIDTH only, never from the platform or the orientation.
enum SizeClass { compact, medium, expanded }

class LayoutService {
  static const double compactMaxWidth = 600;
  static const double mediumMaxWidth = 1024;

  /// compact < 600 (phones), medium 600..1023 (tablet portrait, small windows),
  /// expanded >= 1024 (tablet landscape, desktop, web).
  static SizeClass sizeClassOf(BuildContext context) =>
      sizeClassForWidth(MediaQuery.sizeOf(context).width);

  static SizeClass sizeClassForWidth(double width) {
    if (width < compactMaxWidth) return SizeClass.compact;
    if (width < mediumMaxWidth) return SizeClass.medium;
    return SizeClass.expanded;
  }

  static bool isCompact(BuildContext context) =>
      sizeClassOf(context) == SizeClass.compact;
  static bool isMedium(BuildContext context) =>
      sizeClassOf(context) == SizeClass.medium;
  static bool isExpanded(BuildContext context) =>
      sizeClassOf(context) == SizeClass.expanded;

  /// Content spans the full available width on all screens (no narrow side margins on web).
  static double contentMaxWidth(BuildContext context) {
    return double.infinity;
  }

  /// Constraints capping content width to [contentMaxWidth] on tablet/desktop while
  /// leaving phones unconstrained.
  static BoxConstraints contentConstraints(BuildContext context) =>
      BoxConstraints(maxWidth: contentMaxWidth(context));

  /// Horizontal inset on each side when centering [contentMaxWidth] inside [availableWidth]
  /// (defaults to the full window width).
  static double sideInsetForContent(BuildContext context, [double? availableWidth]) {
    final maxW = contentMaxWidth(context);
    if (!maxW.isFinite) return 0.0;
    final availW = (availableWidth != null && availableWidth.isFinite)
        ? availableWidth
        : MediaQuery.sizeOf(context).width;
    return availW > maxW ? (availW - maxW) / 2 : 0.0;
  }

  /// Lists keep the same single-column layout as mobile; [AppContentWidth] handles wide screens.
  static int listColumns(BuildContext context) => 1;

  /// check if the device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 900 &&
        MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// True on phone-sized windows (< 600px).
  static bool isPhoneLayout(BuildContext context) {
    return isCompact(context);
  }

  /// check if the device is tabled
  static bool isTablet(BuildContext context) {
    return (MediaQuery.of(context).size.width >= 900 &&
        MediaQuery.of(context).size.width < 1200) ||
        (MediaQuery.of(context).orientation == Orientation.landscape &&
            MediaQuery.of(context).size.width < 1200);
  }

  /// check if the device is desctop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// return device screen width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// return device screen height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// check if device has disabled the animation
  static bool disableAnimation(BuildContext context) {
    return PlatformIs.web || (MediaQuery.of(context).disableAnimations);
  }

  /// bind the widget depond on screen size
  static Widget bindWidget(BuildContext context,
      {Widget Function()? mobileWidget,
        Widget Function()? tabletWidget,
        Widget Function()? descktopWidget}) //: assert(context != null)
  {
    //return descktopWidget;
    if (MediaQuery.of(context).size.width > 1200) {
      var c = descktopWidget ??
          tabletWidget ??
          mobileWidget ??
              () => const SizedBox();
      return c();
    }
    if (MediaQuery.of(context).size.width > 650 ||
        MediaQuery.of(context).orientation == Orientation.landscape) {
      var c = tabletWidget ??
          descktopWidget ??
          mobileWidget ??
              () => const SizedBox();
      return c();
    }

    var c = mobileWidget ??
        tabletWidget ??
        descktopWidget ??
            () => const SizedBox();
    return c();
  }

  ///Get Text Size
  static Size textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }
}
