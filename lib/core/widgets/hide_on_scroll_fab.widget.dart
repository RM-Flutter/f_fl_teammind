import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../constants/app_design.dart';

/// Shows / hides floating buttons smoothly while the page scrolls (layout rule 6):
/// scrolling down (reading further) or reaching the end hides them, scrolling up or reaching
/// the top brings them back. The iOS bounce at the end does not bring them back. Only vertical scrolling counts, so horizontal carousels don't affect it.
///
/// [CoreMobileScaffold] and [TemplatePage] already use it. For a plain [Scaffold]:
///
/// ```dart
/// return HideOnScrollFabHost(
///   builder: (context, wrapFab) => Scaffold(
///     floatingActionButton: wrapFab(MyFab()),
///     body: ListView(...),
///   ),
/// );
/// ```
class HideOnScrollFabHost extends StatefulWidget {
  final Widget Function(
      BuildContext context, Widget? Function(Widget? fab) wrapFab) builder;

  /// Set to false to keep the buttons always visible.
  final bool enabled;

  const HideOnScrollFabHost({
    super.key,
    required this.builder,
    this.enabled = true,
  });

  @override
  State<HideOnScrollFabHost> createState() => _HideOnScrollFabHostState();
}

class _HideOnScrollFabHostState extends State<HideOnScrollFabHost> {
  final ValueNotifier<bool> _visible = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  Widget? _wrapFab(Widget? fab) {
    if (fab == null) return null;
    if (!widget.enabled) return fab;
    return HideOnScrollFab(visible: _visible, child: fab);
  }

  @override
  Widget build(BuildContext context) {
    // The listener is always there (even when disabled) so toggling [enabled] never changes
    // the widget tree above the scaffold and never resets its state.
    final child = widget.builder(context, _wrapFab);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (widget.enabled) {
          HideOnScrollFab.handleScroll(_visible, notification);
        } else if (!_visible.value) {
          _visible.value = true;
        }
        return false; // let the notification keep bubbling
      },
      child: child,
    );
  }
}

/// The animated wrapper around the floating button(s). Fades + slides down + shrinks a little
/// when [visible] is false, and ignores taps while hidden.
class HideOnScrollFab extends StatelessWidget {
  final ValueListenable<bool> visible;
  final Widget child;

  const HideOnScrollFab({super.key, required this.visible, required this.child});

  /// Updates [visible] from a scroll notification. Returns nothing; never stops the bubble.
  static void handleScroll(
      ValueNotifier<bool> visible, ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return;

    // Back at the top (or pulled past it by the refresh indicator) → always show.
    if (metrics.pixels <= metrics.minScrollExtent + 4) {
      if (!visible.value) visible.value = true;
      return;
    }

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse && visible.value) {
        visible.value = false; // finger moves up → content scrolls down → hide
      } else if (notification.direction == ScrollDirection.forward &&
          !visible.value) {
        visible.value = true; // scrolling back up → show
      }
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      // Reached the end (or bouncing past it on iOS) → keep hidden. The bounce-back moves
      // upwards without a finger, which must not count as "scrolling up". A real finger drag
      // upwards is still allowed through so the buttons come back.
      final atBottom = metrics.pixels >= metrics.maxScrollExtent - 1;
      if (atBottom && (notification.dragDetails == null || delta > 0)) {
        if (visible.value) visible.value = false;
        return;
      }
      if (notification.dragDetails != null) return;
      // Programmatic / fling scroll: follow its direction too.
      if (delta > 6 && visible.value) {
        visible.value = false;
      } else if (delta < -6 && !visible.value) {
        visible.value = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      child: child,
      builder: (context, isVisible, child) => IgnorePointer(
        ignoring: !isVisible,
        child: AnimatedSlide(
          offset: isVisible ? Offset.zero : const Offset(0, 0.35),
          duration: AppMotion.normal,
          curve: isVisible ? AppMotion.enter : AppMotion.exit,
          child: AnimatedScale(
            scale: isVisible ? 1 : 0.85,
            duration: AppMotion.normal,
            curve: isVisible ? AppMotion.enter : AppMotion.exit,
            child: AnimatedOpacity(
              opacity: isVisible ? 1 : 0,
              duration: AppMotion.normal,
              curve: isVisible ? AppMotion.enter : AppMotion.exit,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
