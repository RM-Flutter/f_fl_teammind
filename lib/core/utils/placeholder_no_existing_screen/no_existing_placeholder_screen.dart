import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/app_styles.dart';

import '../../widgets/dynamic_image_widget.dart';

/// The one "nothing here yet" view of the app: the company logo on a soft tinted disc with two
/// thin signal rings that slowly spread outwards (the logo is a signal itself), then a title and
/// an optional hint line. The block fades in and rises a little using [AppMotion].
///
/// The rings stay still when the device has animations turned off.
/// [compact] is for empty sections inside a page (smaller, no height of its own).
class NoExistingPlaceholderScreen extends StatefulWidget {
  final String title;
  final String? message;
  final double? height;
  final bool compact;
  const NoExistingPlaceholderScreen({
    super.key,
    required this.title,
    this.message,
    this.height,
    this.compact = false,
  });

  @override
  State<NoExistingPlaceholderScreen> createState() =>
      _NoExistingPlaceholderScreenState();
}

class _NoExistingPlaceholderScreenState
    extends State<NoExistingPlaceholderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _ripple.stop();
      _ripple.value = 0.35;
    } else if (!_ripple.isAnimating) {
      _ripple.repeat();
    }
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    final navy = Color(AppColors.secondaryButton);
    final compact = widget.compact;
    final disc = compact ? 64.0 : 88.0;
    final logo = compact ? 34.0 : 48.0;
    final area = compact ? 120.0 : 168.0;

    final content = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: area,
            height: area,
            child: AnimatedBuilder(
              animation: _ripple,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RingsPainter(
                    progress: _ripple.value,
                    color: accent,
                    startRadius: disc / 2,
                    endRadius: area / 2,
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Container(
                  width: disc,
                  height: disc,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.10),
                  ),
                  alignment: Alignment.center,
                  child: DynamicImageWidget(
                    imageUrl: 'assets/images/app_logos.png',
                    width: logo,
                    height: logo,
                    fit: BoxFit.contain,
                    errorWidget: Image.asset(
                      'assets/images/general_images/logo.png',
                      color: Colors.grey,
                      width: logo,
                      height: logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
          Padding(
            padding: AppSpacing.pagePadding,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppStyles.darkContent(context).copyWith(
                fontSize: compact ? 14 : 17,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
          ),
          if (widget.message != null && widget.message!.isNotEmpty) ...[
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: AppStyles.greyContent(context).copyWith(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Center(child: content),
    );
  }
}

/// Two rings spreading from the disc to the edge of the area and fading out, half a cycle apart.
class _RingsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double startRadius;
  final double endRadius;

  _RingsPainter({
    required this.progress,
    required this.color,
    required this.startRadius,
    required this.endRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final offset in const [0.0, 0.5]) {
      final t = (progress + offset) % 1.0;
      final eased = Curves.easeOut.transform(t);
      final radius = startRadius + (endRadius - startRadius) * eased;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.28 * (1 - t));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.progress != progress;
}
