import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The app logo built from its five pieces, which fly in from different directions and lock
/// together. All pieces share the same canvas, so they line up exactly once assembled.
class AnimatedLogoAssembly extends StatefulWidget {
  final double width;
  final Duration duration;

  /// Called once the pieces have finished assembling.
  final VoidCallback? onCompleted;

  /// Show the assembled logo right away, with no animation ([onCompleted] still fires).
  final bool skipAnimation;

  const AnimatedLogoAssembly({
    super.key,
    this.onCompleted,
    this.skipAnimation = false,
    this.width = 190,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<AnimatedLogoAssembly> createState() => _AnimatedLogoAssemblyState();
}

class _AnimatedLogoAssemblyState extends State<AnimatedLogoAssembly>
    with SingleTickerProviderStateMixin {
  static const _dir = 'assets/images/splash_images/logo_piece_';
  // Source art is 464 x 468.
  static const _aspect = 468 / 464;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onCompleted?.call();
        });

  @override
  void initState() {
    super.initState();
    if (widget.skipAnimation) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Progress of one piece, delayed by [start] and lasting [length] (both fractions of the whole).
  Animation<double> _piece(double start, double length) => CurvedAnimation(
        parent: _controller,
        curve: Interval(start, math.min(1, start + length), curve: Curves.easeOutBack),
      );

  Widget _buildPiece(
    String name,
    Animation<double> t, {
    Offset from = Offset.zero,
    double fromScale = 1,
    double fromTurns = 0,
  }) {
    final w = widget.width;
    return AnimatedBuilder(
      animation: t,
      builder: (_, child) {
        final p = t.value; // easeOutBack overshoots 1 slightly, which gives the "snap" feel
        return Opacity(
          opacity: (p * 3).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(from.dx * w * (1 - p), from.dy * w * (1 - p)),
            child: Transform.rotate(
              angle: fromTurns * 2 * math.pi * (1 - p),
              child: Transform.scale(
                scale: fromScale + (1 - fromScale) * p,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Image.asset('$_dir$name.png', width: w, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.width * _aspect,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildPiece('left', _piece(0.00, 0.50), from: const Offset(-0.9, 0.15), fromTurns: -0.15),
          _buildPiece('right', _piece(0.08, 0.50), from: const Offset(0.9, 0.15), fromTurns: 0.15),
          _buildPiece('ring', _piece(0.22, 0.50), fromScale: 0.2, fromTurns: -0.5),
          _buildPiece('top', _piece(0.40, 0.50), from: const Offset(0, -0.9)),
          _buildPiece('dot', _piece(0.58, 0.42), fromScale: 0),
        ],
      ),
    );
  }
}
