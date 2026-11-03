import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The design scale of the app. Screens use these instead of raw numbers, so every card,
/// button and gap looks the same everywhere. The theme (AppThemeService) uses the same
/// values, so plain Material widgets (Card, ElevatedButton, Chip, dialogs...) match too.
///
/// Decisions: pill-shaped buttons; cards are white with one soft shadow and no border.

/// Corner radius steps. Pick the closest step, never a raw number.
abstract class AppRadius {
  static const double xs = 4; // tags, progress bars
  static const double sm = 8; // small chips, thumbnails, icon boxes
  static const double md = 12; // cards, inputs, list tiles
  static const double lg = 16; // bottom sheets, dialogs, large cards
  static const double xl = 24; // hero headers
  static const double pill = 999; // buttons, status badges, search bars

  static final BorderRadius card = BorderRadius.circular(md);
  static final BorderRadius input = BorderRadius.circular(md);
  static final BorderRadius sheet = BorderRadius.circular(lg);
  static final BorderRadius button = BorderRadius.circular(pill);
}

/// Spacing steps (4-point grid).
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Left/right padding of every page.
  static const double page = 16;

  /// Space between cards in a list.
  static const double cardGap = 12;

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: page);
}

/// The one shadow used by cards (no borders on cards).
abstract class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F101828), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08101828), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Floating things above the content (FAB, sticky bars).
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x1A101828), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

/// Button sizes. All buttons are pill shaped (AppRadius.pill).
abstract class AppButtonSize {
  static const double height = 48; // main actions (Submit, Save, Login)
  static const double compactHeight = 40; // secondary/inline actions
  static const double minWidth = 64;
  static const double fontSize = 14;
  static const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 24);
}

/// Ready-made decorations for the cases where a widget can't be an [AppCard].
abstract class AppDecorations {
  static BoxDecoration card({Color? color, BorderRadius? radius}) => BoxDecoration(
        color: color ?? Color(AppColors.cardBackground),
        borderRadius: radius ?? AppRadius.card,
        boxShadow: AppShadows.card,
      );
}
