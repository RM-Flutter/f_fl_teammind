import 'package:flutter/material.dart';

/// Fades its child in while sliding it in from an offset (fractions of its own size) and scaling it
/// up slightly. Use [delay] to stagger several siblings.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetX;
  final double offsetY;
  final double beginScale;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offsetX = 0,
    this.offsetY = 0.25,
    this.beginScale = 0.92,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: Offset(widget.offsetX, widget.offsetY), end: Offset.zero)
          .animate(_curve);
  late final Animation<double> _scale =
      Tween<double>(begin: widget.beginScale, end: 1).animate(_curve);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

/// Plays [FadeSlideIn]-style entrance the first time the child scrolls into view of the nearest
/// vertical scrollable. Items already visible on first layout animate after [initialDelay].
class ScrollRevealItem extends StatefulWidget {
  final Widget child;
  final Duration initialDelay;
  final Duration duration;
  final double offsetY;

  const ScrollRevealItem({
    super.key,
    required this.child,
    this.initialDelay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offsetY = 0.2,
  });

  @override
  State<ScrollRevealItem> createState() => _ScrollRevealItemState();
}

class _ScrollRevealItemState extends State<ScrollRevealItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: Offset(0, widget.offsetY), end: Offset.zero)
          .animate(_curve);
  late final Animation<double> _scale =
      Tween<double>(begin: 0.94, end: 1).animate(_curve);

  final List<ScrollableState> _scrollables = [];
  bool _revealed = false;
  bool _frameCheckQueued = false;
  final DateTime _createdAt = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Every vertical scrollable above this item: the nearest one can be a shrink-wrapped,
    // non-scrolling list while the real page scroll is further up.
    _scrollables.clear();
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        _scrollables.add(element.state as ScrollableState);
      }
      return true;
    });
    _queueFrameCheck();
  }

  /// Check the position after every frame until revealed. The item can move into view without
  /// any scroll (data loads, header settles, sections above animate), so scroll events alone
  /// are not enough. Post-frame callbacks never force a frame, so an idle screen costs nothing.
  void _queueFrameCheck() {
    if (_revealed || _frameCheckQueued) return;
    _frameCheckQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameCheckQueued = false;
      if (!mounted || _revealed) return;
      _check();
      _queueFrameCheck();
    });
  }

  void _check() {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize || !box.attached) return;
    final top = box.localToGlobal(Offset.zero).dy;
    // Reveal once the item is a little inside every vertical scrollable's viewport (and the
    // screen), so the entrance is actually seen.
    const inset = 40.0;
    var limit = MediaQuery.of(context).size.height - inset;
    for (final scrollable in _scrollables) {
      final axis = scrollable.widget.axisDirection;
      if (axis != AxisDirection.down && axis != AxisDirection.up) continue;
      final viewport = scrollable.context.findRenderObject();
      if (viewport is! RenderBox || !viewport.hasSize) continue;
      final bottom = viewport.localToGlobal(Offset(0, viewport.size.height)).dy;
      if (bottom - inset < limit) limit = bottom - inset;
    }
    if (top >= limit) return;

    _revealed = true;
    // Items visible while the screen is first settling keep their staggered delay
    final settling = DateTime.now().difference(_createdAt) < const Duration(milliseconds: 1500);
    final delay = settling ? widget.initialDelay : Duration.zero;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
