import 'package:flutter/material.dart';

/// The design scale of the app. Screens use these instead of raw numbers, so every card,
/// button and gap looks the same everywhere. The theme (AppThemeService) uses the same
/// values, so plain Material widgets (Card, ElevatedButton, Chip, dialogs...) match too.
///
/// Decisions: pill-shaped buttons; cards are white with a subtle 12% grey border and a soft 3% shadow.
///
/// ─── LAYOUT RULES (follow these on every screen) ─────────────────────────────────────────
/// 1. Page edges: every screen keeps its content [AppSpacing.page] (16) from the left/right
///    edge. Use [AppSpacing.pagePadding] (or [AppSpacing.listPadding] for scrolling lists).
///    Only the outermost widget of a page adds this padding. Sections and cards inside it add
///    NO extra horizontal padding/margin, so every card, title and header lines up on the same
///    vertical edge. Horizontal carousels put the page padding on the scroll view itself
///    (`padding: AppSpacing.pagePadding`) so the first item lines up and the list still scrolls
///    to the screen edge.
/// 2. Full-bleed blocks (coloured section backgrounds, headers) span the whole width and put
///    [AppSpacing.page] inside them, so their content lines up with the rest of the page.
/// 3. Vertical rhythm: [AppSpacing.section] between sections, [AppSpacing.sectionHeaderGap]
///    between a section title row and its first card, [AppSpacing.cardGap] between cards.
///    Use the `gapH*` / `gapW*` constants from app_sizes.dart instead of `SizedBox(height: n)`.
/// 4. Cards: always [AppCard] / [AppCard.listItem] (or [AppDecorations.card]). No custom
///    shadows, radii or margins on list cards.
/// 5. Loading: list screens show [AppShimmerList] (core/utils/custom_shimmer_loading), which
///    draws placeholders with the exact shape of [AppCard.listItem]. No spinners for a first
///    page of a list.
/// 6. Floating buttons (see rule 11) hide while the user scrolls down and come back when they scroll up.
///    [CoreMobileScaffold] and [TemplatePage] do this automatically; a plain [Scaffold] wraps
///    itself in [HideOnScrollFabHost] (core/widgets/hide_on_scroll_fab.widget.dart).
/// 7. Animations use [AppMotion] durations and curves.
/// 8. Rows above a list (switcher, scope chips, active filters, shortcut card) each own
///    [AppSpacing.md] (12) ABOVE them, and the list itself starts with [AppSpacing.md] on top
///    ([AppSpacing.listPadding]). So app bar -> first row, row -> row and last row -> first card
///    are all 12. Never add a `SizedBox` under a header row.
/// 9. Never wrap a `Scaffold` in a `SafeArea` (it paints black bars behind the notch and the
///    home indicator). The app bar and the lists already handle the insets.
/// 10. Responsive: decide layout from `LayoutService.sizeClassOf(context)` (compact < 600,
///    medium < 1024, expanded) and never from the platform or the orientation. No heights as a
///    fraction of the screen (`.sh`, `height * 0.x`) for sizes. Page width is limited by
///    `AppContentWidth` (already inside `TemplatePage` / `CoreMobileScaffold`); lists of small
///    cards use `AppAdaptiveWrap` (1 / 2 / 3 columns). Wide windows get a side `NavigationRail`.
/// 13. Shadows: only `AppShadows.none / card / raised / overlay` (or `AppElevation.*` for widgets
///    that take a number). No `BoxShadow(` and no raw `elevation: n` outside this file and the
///    theme. Cards are always radius `AppRadius.md` + `AppBorders.card` + `AppShadows.card`
///    (use `AppCard`). Run `tool/check_design_tokens.sh` before committing.
/// 12. Status colours (orange, green, red, blue...) are never drawn raw as text or thin
///    borders: use `AppColors.statusTones(color)` (`text`, `ring`, `border`, `tint`) or just
///    `AppStatusBadge` / `AppCardLeadingAvatar`, which already do. Never `Colors.orange`.
/// 11. The floating button is always `AppFab` (a round, icon-only button; words go in `tooltip`).

/// Corner radius steps. Pick the closest step, never a raw number.
abstract class AppRadius {
  static const double xs = 4; // tags, progress bars
  static const double sm = 8; // small chips, thumbnails, icon boxes
  static const double md = 12; // cards, inputs, list tiles
  static const double lg = 16; // bottom sheets, dialogs, large cards, status badges
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

  /// Left/right padding of every page (rule 1). The ONE value for page edges.
  static const double page = 16;

  /// Space between cards in a list.
  static const double cardGap = 10;

  /// Vertical space between two sections of a page (e.g. home "My requests" → "Notifications").
  static const double section = 16;

  /// Space between a section title row and its first card.
  static const double sectionHeaderGap = 8;

  /// Smallest size of anything that can be tapped.
  static const double tapTarget = 44;

  /// Height of a section title row (title + "View all"), so every section header is the same.
  static const double sectionHeaderHeight = 36;

  /// Empty space under the last item of a scrolling list, so floating buttons never cover it.
  static const double listBottom = 96;

  /// Standard card internal padding matching TeamMemberStatusCard (h: 14, v: 12).
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: 14, vertical: 12);

  /// Left/right page padding (rule 1).
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: page);

  /// Page padding on all four sides (forms, details pages).
  static const EdgeInsets pageAll = EdgeInsets.all(page);

  /// Padding of a scrolling list of cards: page edges + a little air on top + room for the FAB.
  static const EdgeInsets listPadding =
      EdgeInsets.fromLTRB(page, md, page, listBottom);

  /// Padding of a full-bleed section (coloured background) so its content lines up with the page.
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: page, vertical: lg);
}

/// Durations and curves for every animation in the app (rule 7).
abstract class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Things entering / appearing.
  static const Curve enter = Curves.easeOutCubic;

  /// Things leaving / disappearing.
  static const Curve exit = Curves.easeInCubic;
}

/// Shimmer / skeleton loading (rule 5). The placeholders copy the shape of [AppCard.listItem].
abstract class AppShimmer {
  /// Pulse colours of a placeholder block.
  static final Color base = Colors.black.withOpacity(0.04);
  static final Color highlight = Colors.black.withOpacity(0.09);

  /// One pulse (there and back is twice this).
  static const Duration period = Duration(milliseconds: 900);

  /// Default corner of a placeholder block (text lines, boxes).
  static const double radius = AppRadius.xs;

  /// Height of a placeholder text line (title / subtitle).
  static const double titleLine = 12;
  static const double subtitleLine = 10;

  /// Size of the leading avatar of a list card (same as [AppCardLeadingAvatar]).
  static const double avatar = 46;

  /// How many placeholder cards a list shows while loading.
  static const int listCount = 6;
}

/// Standard borders used across cards.
abstract class AppBorders {
  static final Border card = Border.all(
    color: Colors.grey.withOpacity(0.12),
    width: 1.0,
  );

  static final BorderSide cardSide = BorderSide(
    color: Colors.grey.withOpacity(0.12),
    width: 1.0,
  );
}

/// The unified shadow used by cards (matching TeamMemberStatusCard).
abstract class AppShadows {
  // One shadow colour for the whole app: a very dark navy, not black, so every level looks warm.
  static const Color _ink = Color(0xFF101828);

  /// Level 0: flat. Fields, chips and cards that sit inside another card (a border only).
  static const List<BoxShadow> none = [];

  /// Level 1: every card.
  static final List<BoxShadow> card = [
    BoxShadow(color: _ink.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
    BoxShadow(color: _ink.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
  ];

  /// Level 2: floating things above the content (FAB, sticky bars, banners over a map).
  static final List<BoxShadow> raised = [
    BoxShadow(color: _ink.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  /// Level 3: layers above the whole page (bottom sheets, dialogs, dropdown overlays).
  static final List<BoxShadow> overlay = [
    BoxShadow(color: _ink.withValues(alpha: 0.16), blurRadius: 40, offset: const Offset(0, 16)),
  ];
}

/// Material `elevation` steps for widgets that can only take a number (Card, Material, FAB,
/// dialogs). They match the [AppShadows] levels; never write a raw elevation number.
abstract class AppElevation {
  static const double none = 0;
  static const double card = 1;
  static const double raised = 4;
  static const double overlay = 8;
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
  static BoxDecoration card({
    Color? color,
    BorderRadius? radius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) =>
      BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: radius ?? AppRadius.card,
        border: border ?? AppBorders.card,
        boxShadow: boxShadow ?? AppShadows.card,
      );
}
