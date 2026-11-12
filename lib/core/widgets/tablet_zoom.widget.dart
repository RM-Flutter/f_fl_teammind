import 'dart:math' as math;
import 'dart:ui' show FlutterView;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// "Display Zoom" for tablets: draws the whole app [factor] times bigger (text, icons, spacing,
/// cards, dialogs, sheets), the way iOS Display Zoom does. The app is laid out on a smaller
/// logical screen (size / factor) and scaled up to fill the real one, so every screen keeps its
/// phone proportions instead of showing phone-sized text on a large display.
///
/// Only on native tablets: never on the web, never on phones. The decision uses the physical
/// display (not the window), so split screen on a tablet does not switch it on and off.
/// The factor never pushes the logical short side below 620 (just above the 600 tablet
/// breakpoint), so every tablet keeps its tablet layout and `ScreenUtil` keeps treating it as one.
///
/// Replaces `MediaQuery.fromView` at the top of the app: everything below (ScreenUtil,
/// MaterialApp, `MediaQuery.of`) sees the zoomed size, insets and keyboard.
class TabletZoom extends StatelessWidget {
  final Widget child;

  const TabletZoom({super.key, required this.child});

  /// Upper limit of the zoom (reached by the large 12.9" / 13" iPads).
  static const double maxFactor = 1.45;

  /// The short side every zoomed tablet is laid out at (or more): a little above the 600 tablet
  /// breakpoint, so the bigger the tablet, the bigger the zoom. iPad mini (744) ×1.2,
  /// iPad / iPad Air 11" (820–834) ×1.32–1.35, iPad Pro 13" (1032) ×1.45.
  static const double _targetLogicalShortestSide = 620;

  /// Zoom factor for this device: 1 on the web, on phones, and on tablets too small to zoom.
  static double factorFor(FlutterView view) {
    if (kIsWeb) return 1;
    final display = view.display;
    final shortest = math.min(display.size.width, display.size.height) / display.devicePixelRatio;
    if (shortest < _targetLogicalShortestSide) return 1;
    return (shortest / _targetLogicalShortestSide).clamp(1.0, maxFactor);
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final factor = factorFor(view);
    return MediaQuery.fromView(
      view: view,
      child: factor == 1
          ? child
          : Builder(builder: (context) {
              final real = MediaQuery.of(context);
              final zoomed = real.copyWith(
                size: real.size / factor,
                devicePixelRatio: real.devicePixelRatio * factor,
                padding: real.padding / factor,
                viewPadding: real.viewPadding / factor,
                viewInsets: real.viewInsets / factor,
                systemGestureInsets: real.systemGestureInsets / factor,
              );
              return MediaQuery(
                data: zoomed,
                child: FittedBox(
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                  child: SizedBox.fromSize(size: zoomed.size, child: child),
                ),
              );
            }),
    );
  }
}
