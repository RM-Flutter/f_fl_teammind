import 'package:app_test/core/constants/app_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Smooth entrance of a list item: fades in and rises. Items that appear in the same frame
/// (a freshly loaded list) are staggered one after another, up to 8 of them, so a long list never
/// waits; items that scroll into view later play alone. Nothing moves when the device has
/// animations turned off. [index] is optional and only needed to force a specific order.
class AppListEntrance extends StatefulWidget {
  final int? index;
  final Widget child;
  const AppListEntrance({super.key, this.index, required this.child});

  // Counts the items created in the current frame; reset after the frame.
  static int _inFrame = 0;
  static bool _resetScheduled = false;

  @override
  State<AppListEntrance> createState() => _AppListEntranceState();
}

class _AppListEntranceState extends State<AppListEntrance>
    with SingleTickerProviderStateMixin {
  static const _step = 70; // ms between two items
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final n = widget.index ?? AppListEntrance._inFrame++;
    if (!AppListEntrance._resetScheduled) {
      AppListEntrance._resetScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        AppListEntrance._inFrame = 0;
        AppListEntrance._resetScheduled = false;
      });
    }
    final delay = _step * (n < 8 ? n : 0);
    const total = 500;
    _c = AnimationController(
        vsync: this, duration: Duration(milliseconds: total + delay));
    _t = CurvedAnimation(
      parent: _c,
      curve: Interval(delay / (total + delay), 1, curve: AppMotion.enter),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
            offset: Offset(0, 28 * (1 - _t.value)), child: child),
      ),
    );
  }
}
