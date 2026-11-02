import 'dart:async';
import 'dart:math' as math;

import 'package:app_test/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum AssistantAvatarMode { idle, listening, speaking }

/// شخصية "Mr. TeamMind": روبوت بألوان الشعار، مرسوم بالكود حتى يتحرك كل جزء
/// وحده ويبقى حاداً بأي حجم.
/// - يتكلم: الفم شرائط معادل صوت تقفز مع كل كلمة، وموجات تخرج من الهوائي، والرأس يهتز.
/// - يستمع: الرأس يميل، العينان تتسعان، والفم "o" يكبر مع صوت المستخدم.
/// - خامل: ابتسامة، نظرات خفيفة، ورمش عشوائي.
class AssistantAvatarWidget extends StatefulWidget {
  final AssistantAvatarMode mode;

  /// مستوى صوت الميكروفون 0..1 أثناء الاستماع.
  final double level;

  /// يزيد مع كل كلمة منطوقة.
  final int wordTick;
  final double size;

  const AssistantAvatarWidget({
    super.key,
    required this.mode,
    this.level = 0,
    this.wordTick = 0,
    this.size = 96,
  });

  @override
  State<AssistantAvatarWidget> createState() => _AssistantAvatarWidgetState();
}

class _AssistantAvatarWidgetState extends State<AssistantAvatarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  late final AnimationController _kick =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  late final AnimationController _blink =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
  final _random = math.Random();
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 1800 + _random.nextInt(3200)), () async {
      if (!mounted) return;
      await _blink.forward(from: 0);
      if (!mounted) return;
      await _blink.reverse();
      if (mounted) _scheduleBlink();
    });
  }

  @override
  void didUpdateWidget(AssistantAvatarWidget old) {
    super.didUpdateWidget(old);
    if (widget.wordTick != old.wordTick && widget.mode == AssistantAvatarMode.speaking) {
      _kick.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _loop.dispose();
    _kick.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * _AvatarPainter.aspect,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _kick, _blink]),
        builder: (_, __) => CustomPaint(
          painter: _AvatarPainter(
            mode: widget.mode,
            t: _loop.value,
            kick: _kick.isAnimating ? 1 - Curves.easeOut.transform(_kick.value) : 0,
            blink: _blink.value,
            level: widget.level.clamp(0.0, 1.0),
          ),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  // لوحة الرسم 100 x 112 وحدة، تُكبَّر لحجم الـ widget.
  static const double aspect = 112 / 100;

  final AssistantAvatarMode mode;
  final double t, kick, blink, level;

  _AvatarPainter({
    required this.mode,
    required this.t,
    required this.kick,
    required this.blink,
    required this.level,
  });

  static const navy = Color(AppColors.brandNavy);
  static const blue = Color(AppColors.brandBlue);
  static const visor = Color(0xFF04052E);

  double _wave(double phase, [double speed = 1]) =>
      math.sin(2 * math.pi * (t * speed - phase));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);

    final speaking = mode == AssistantAvatarMode.speaking;
    final listening = mode == AssistantAvatarMode.listening;

    _paintBody(canvas);

    // الرأس: يهتز بخفة، ويميل نحو المستخدم أثناء الاستماع.
    final bob = speaking ? _wave(0, 4) * 1.2 + kick * -1.5 : _wave(0) * 1.2;
    final tilt = listening ? -0.07 * (0.4 + 0.6 * level) : 0.0;
    canvas.save();
    canvas.translate(50, 84 + bob);
    canvas.rotate(tilt);
    canvas.translate(-50, -84);
    _paintAntenna(canvas, speaking, listening);
    _paintHead(canvas);
    _paintEyes(canvas, listening, speaking);
    _paintMouth(canvas, speaking, listening);
    canvas.restore();

    canvas.restore();
  }

  void _paintBody(Canvas canvas) {
    // الكتفان
    final body = RRect.fromRectAndCorners(
      const Rect.fromLTRB(24, 90, 76, 112),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [navy, Color(0xFF0E1180)],
        ).createShader(body.outerRect),
    );
    // الرقبة
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTRB(44, 82, 56, 92), const Radius.circular(3)),
      Paint()..color = const Color(0xFF14178C),
    );
    // ربطة العنق (Mr.)
    final bow = Paint()..color = blue;
    canvas.drawPath(
        Path()
          ..moveTo(50, 96)
          ..lineTo(39, 91)
          ..quadraticBezierTo(37, 96, 39, 101)
          ..close(),
        bow);
    canvas.drawPath(
        Path()
          ..moveTo(50, 96)
          ..lineTo(61, 91)
          ..quadraticBezierTo(63, 96, 61, 101)
          ..close(),
        bow);
    canvas.drawCircle(const Offset(50, 96), 3, Paint()..color = const Color(0xFF1F6FD6));
  }

  void _paintAntenna(Canvas canvas, bool speaking, bool listening) {
    canvas.drawLine(
      const Offset(50, 22),
      const Offset(50, 11),
      Paint()
        ..color = const Color(0xFF14178C)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    // موجات إشارة مثل أقواس الشعار، تخرج أثناء الكلام.
    if (speaking) {
      for (var i = 0; i < 2; i++) {
        final p = (t * 3 + i * 0.5) % 1;
        final r = 7 + p * 9;
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(50, 8), radius: r),
          -math.pi * 0.8,
          math.pi * 0.6,
          false,
          Paint()
            ..color = blue.withValues(alpha: (1 - p) * 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    final glow = speaking ? 0.6 + 0.4 * kick : (listening ? 0.4 + 0.6 * level : 0.25 + 0.15 * _wave(0));
    canvas.drawCircle(
      const Offset(50, 8),
      6 + 3 * glow,
      Paint()
        ..color = blue.withValues(alpha: 0.35 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(const Offset(50, 8), 5, Paint()..color = blue);
    canvas.drawCircle(const Offset(48.3, 6.3), 1.5, Paint()..color = Colors.white.withValues(alpha: 0.7));
  }

  void _paintHead(Canvas canvas) {
    // الأذنان
    final ear = Paint()..color = blue;
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTRB(7, 42, 15, 64), const Radius.circular(4)), ear);
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTRB(85, 42, 93, 64), const Radius.circular(4)), ear);

    final head = RRect.fromRectAndRadius(const Rect.fromLTRB(13, 21, 87, 85), const Radius.circular(24));
    canvas.drawRRect(
      head.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(
      head,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2196), navy],
        ).createShader(head.outerRect),
    );

    // شاشة الوجه
    final face = RRect.fromRectAndRadius(const Rect.fromLTRB(21, 32, 79, 76), const Radius.circular(17));
    canvas.drawRRect(
      face,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0E5A), visor],
        ).createShader(face.outerRect),
    );
    // لمعة
    canvas.drawArc(
      const Rect.fromLTRB(25, 35, 60, 60),
      math.pi * 1.05,
      math.pi * 0.35,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintEyes(Canvas canvas, bool listening, bool speaking) {
    // نظرات خفيفة في الخمول
    final look = mode == AssistantAvatarMode.idle ? _wave(0.2) * 1.6 : 0.0;
    final open = 1 - blink * 0.9;
    final h = (listening ? 13.0 + 2 * level : 11.0) * open;
    const w = 9.0;
    for (final cx in [38.0, 62.0]) {
      final rect = Rect.fromCenter(center: Offset(cx + look, 50), width: w, height: h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2.5), const Radius.circular(6)),
        Paint()
          ..color = blue.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4.5)), Paint()..color = blue);
      if (open > 0.5) {
        canvas.drawCircle(
          Offset(cx + look - 1.6, 50 - h * 0.22),
          1.4,
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      }
    }
  }

  void _paintMouth(Canvas canvas, bool speaking, bool listening) {
    final paint = Paint()
      ..color = blue
      ..strokeCap = StrokeCap.round;
    if (speaking) {
      // شرائط معادل صوت
      const heights = [0.55, 0.85, 1.0, 0.85, 0.55];
      for (var i = 0; i < 5; i++) {
        final wobble = 0.5 + 0.5 * _wave(i * 0.17, 6);
        final hh = 2 + 8 * heights[i] * (0.35 + 0.65 * math.max(kick, wobble * 0.6));
        canvas.drawLine(
          Offset(40 + i * 5.0, 65 - hh / 2),
          Offset(40 + i * 5.0, 65 + hh / 2),
          paint..strokeWidth = 3,
        );
      }
    } else if (listening) {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(50, 65), width: 6 + 5 * level, height: 3.5 + 5 * level),
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    } else {
      canvas.drawArc(
        const Rect.fromLTRB(42, 56, 58, 68),
        math.pi * 0.15,
        math.pi * 0.7,
        false,
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
  }

  @override
  bool shouldRepaint(_AvatarPainter old) =>
      old.t != t || old.kick != kick || old.blink != blink || old.level != level || old.mode != mode;
}
