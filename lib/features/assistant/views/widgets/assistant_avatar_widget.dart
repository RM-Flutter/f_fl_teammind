import 'dart:async';
import 'dart:math' as math;

import 'package:app_test/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_design.dart';

enum AssistantAvatarMode { idle, listening, speaking }

/// شخصية "Mr. TeamMind": شاب بشعر مجعد ونظارة وقلم خلف أذنه، رسم خطي بلوني
/// الشعار. مرسوم بالكود حتى يتحرك كل جزء وحده ويبقى حاداً بأي حجم.
/// - خامل: يتمايل بهدوء، يرمش، ويبتسم أحياناً بعيون ^^.
/// - يستمع: فم "o" يكبر ويصغر مع صوت المستخدم، والرأس يميل قليلاً.
/// - يتكلم: الفم يفتح ويقفل مع كل كلمة، يبتسم ^^ في بداية الرد، والقلم يهتز.
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
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  // فتح الفم مع كل كلمة: يفتح بسرعة ثم يقفل.
  late final AnimationController _talk =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  late final AnimationController _blink =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
  // لحظة الابتسامة ^^ (0..1).
  late final AnimationController _happy =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  final _random = math.Random();
  Timer? _blinkTimer;
  Timer? _happyTimer;

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
    _scheduleIdleSmile();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 1800 + _random.nextInt(3000)), () async {
      if (!mounted) return;
      if (_happy.value < 0.5) {
        await _blink.forward(from: 0);
        if (!mounted) return;
        await _blink.reverse();
      }
      if (mounted) _scheduleBlink();
    });
  }

  /// ابتسامة ^^ قصيرة كل فترة أثناء الخمول.
  void _scheduleIdleSmile() {
    _happyTimer = Timer(Duration(milliseconds: 6000 + _random.nextInt(5000)), () {
      if (!mounted) return;
      if (widget.mode == AssistantAvatarMode.idle) _smile(const Duration(milliseconds: 1400));
      _scheduleIdleSmile();
    });
  }

  Future<void> _smile(Duration hold) async {
    await _happy.forward();
    await Future.delayed(hold);
    if (mounted) await _happy.reverse();
  }

  @override
  void didUpdateWidget(AssistantAvatarWidget old) {
    super.didUpdateWidget(old);
    if (widget.mode == AssistantAvatarMode.speaking && old.mode != AssistantAvatarMode.speaking) {
      _smile(const Duration(milliseconds: 700)); // يبدأ الرد بابتسامة
    }
    if (widget.mode != AssistantAvatarMode.idle && _happy.value > 0 && !_happy.isAnimating) {
      _happy.reverse();
    }
    if (widget.wordTick != old.wordTick && widget.mode == AssistantAvatarMode.speaking) {
      _talk.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _happyTimer?.cancel();
    _loop.dispose();
    _talk.dispose();
    _blink.dispose();
    _happy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _talk, _blink, _happy]),
        builder: (_, __) {
          // فتح الفم: قمة سريعة ثم إغلاق، مع اهتزاز خفيف طول الكلام.
          final talkPulse = _talk.isAnimating ? math.sin(math.pi * _talk.value) : 0.0;
          final speaking = widget.mode == AssistantAvatarMode.speaking;
          final chatter = speaking ? 0.25 + 0.2 * math.sin(2 * math.pi * _loop.value * 9) : 0.0;
          return CustomPaint(
            painter: _AvatarPainter(
              mode: widget.mode,
              t: _loop.value,
              open: speaking ? math.max(talkPulse, chatter).clamp(0.0, 1.0) : 0,
              blink: _blink.value,
              happy: Curves.easeOut.transform(_happy.value),
              level: widget.level.clamp(0.0, 1.0),
            ),
          );
        },
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  // الرسم على لوحة 540 x 540 وحدة (نفس مقاس التصميم الأصلي) ثم يُكبَّر.
  static const double _canvas = 540;

  final AssistantAvatarMode mode;
  final double t, open, blink, happy, level;

  _AvatarPainter({
    required this.mode,
    required this.t,
    required this.open,
    required this.blink,
    required this.happy,
    required this.level,
  });

  static const navy = Color(AppColors.brandNavy);
  static const blue = Color(AppColors.brandBlue);

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _white = Paint()..color = Colors.white;

  double _wave(double phase, [double speed = 1]) =>
      math.sin(2 * math.pi * (t * speed - phase));

  /// قوس بين النقطة الحالية و[to]، منتفخ بمقدار [bulge] عمودياً على الاتجاه.
  static void _bump(Path p, Offset from, Offset to, double bulge) {
    final d = to - from;
    final n = Offset(-d.dy, d.dx) / d.distance;
    final c = (from + to) / 2 + n * bulge;
    p.quadraticBezierTo(c.dx, c.dy, to.dx, to.dy);
  }

  static Path _chain(List<Offset> pts, List<double> bulges, {Path? into}) {
    final p = into ?? (Path()..moveTo(pts.first.dx, pts.first.dy));
    for (var i = 1; i < pts.length; i++) {
      _bump(p, pts[i - 1], pts[i], bulges[i - 1]);
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _canvas);

    final speaking = mode == AssistantAvatarMode.speaking;
    final listening = mode == AssistantAvatarMode.listening;

    // تمايل الرأس، وميل بسيط أثناء الاستماع.
    final bob = _wave(0) * (speaking ? 6 : 4);
    final tilt = listening ? -0.05 * (0.4 + 0.6 * level) : 0.015 * _wave(0.3);
    canvas.translate(270, 290 + bob);
    canvas.rotate(tilt);
    canvas.translate(-270, -290);

    _paintPencil(canvas, speaking);
    _paintFace(canvas);
    _paintHair(canvas);
    _paintGlassesAndEyes(canvas);
    _paintNoseAndMouth(canvas, speaking, listening);

    canvas.restore();
  }

  // القلم خلف الأذن اليمنى (يُرسم أولاً فتغطيه الأذن).
  void _paintPencil(Canvas canvas, bool speaking) {
    final wiggle = (speaking ? 0.05 : 0.02) * _wave(0.1, speaking ? 3 : 1);
    canvas.save();
    canvas.translate(452, 276);
    canvas.rotate(0.162 + wiggle);
    final body = RRect.fromRectAndCorners(
      const Rect.fromLTRB(-17, -138, 17, 88),
      topLeft: const Radius.circular(AppRadius.sm),
      topRight: const Radius.circular(AppRadius.sm),
    );
    canvas.drawRRect(body, _white);
    final tip = Path()
      ..moveTo(-17, 88)
      ..lineTo(0, 138)
      ..lineTo(17, 88);
    canvas.drawPath(tip, _white);
    final s = _stroke(navy, 12);
    canvas.drawRRect(body, s);
    canvas.drawPath(tip, s);
    canvas.drawLine(const Offset(-17, -106), const Offset(17, -106), s); // الممحاة
    canvas.drawLine(const Offset(-6, 120), const Offset(6, 120), s..strokeWidth = 14); // سن القلم
    canvas.restore();
  }

  void _paintFace(Canvas canvas) {
    final blueStroke = _stroke(blue, 21);
    // الأذنان: شكل C ممتلئ بالأبيض (الأذن اليمنى تغطي القلم).
    for (final side in [-1.0, 1.0]) {
      final x0 = 264 + side * 150; // خط الوجه
      final ear = Path()
        ..moveTo(x0, 262)
        ..cubicTo(x0 + side * 50, 244, x0 + side * 56, 340, x0, 332);
      canvas.drawPath(ear, _white);
      canvas.drawPath(ear, blueStroke);
    }
    final face = Path()
      ..moveTo(114, 200)
      ..lineTo(114, 330)
      ..cubicTo(114, 420, 182, 478, 264, 478)
      ..cubicTo(346, 478, 414, 420, 414, 330)
      ..lineTo(414, 200)
      ..close();
    canvas.drawPath(face, _white);
    canvas.drawPath(
      Path()
        ..moveTo(114, 200)
        ..lineTo(114, 330)
        ..cubicTo(114, 420, 182, 478, 264, 478)
        ..cubicTo(346, 478, 414, 420, 414, 330)
        ..lineTo(414, 200),
      blueStroke,
    );
  }

  void _paintHair(Canvas canvas) {
    // تموج بسيط في الشعر
    final sway = 2.0 * _wave(0.15);
    // الحد الخارجي (من أسفل اليسار مع عقارب الساعة)، كل قوس منتفخ للخارج.
    final outer = [
      const Offset(100, 236),
      const Offset(100, 146),
      Offset(150, 80 + sway),
      Offset(222, 56 + sway),
      Offset(300, 50 + sway),
      Offset(392, 98 + sway),
      const Offset(430, 160),
      const Offset(432, 236),
    ];
    final outerBulge = [-30.0, -30.0, -28.0, -30.0, -34.0, -26.0, -16.0];
    // الحد السفلي (الغرة) من اليمين لليسار: تجاعيد منتفخة لأعلى.
    final bangs = [
      const Offset(432, 236),
      const Offset(398, 206),
      const Offset(342, 198),
      const Offset(286, 208),
      const Offset(226, 200),
      const Offset(166, 210),
      const Offset(124, 224),
      const Offset(100, 236),
    ];
    final bangsBulge = [18.0, 26.0, 24.0, 26.0, 26.0, 20.0, 10.0];
    final hair = _chain(outer, outerBulge);
    _chain(bangs, bangsBulge, into: hair);
    hair.close();
    canvas.drawPath(hair, _white);
    canvas.drawPath(hair, _stroke(navy, 19));
  }

  void _paintGlassesAndEyes(Canvas canvas) {
    final s = _stroke(navy, 21);
    const left = Rect.fromLTRB(132, 244, 244, 326);
    const right = Rect.fromLTRB(284, 244, 400, 326);
    canvas.drawRRect(RRect.fromRectAndRadius(left, const Radius.circular(AppRadius.lg)), s);
    canvas.drawRRect(RRect.fromRectAndRadius(right, const Radius.circular(AppRadius.lg)), s);
    canvas.drawLine(const Offset(244, 268), const Offset(284, 268), s); // الجسر
    canvas.drawLine(const Offset(132, 266), const Offset(108, 264), s); // الذراعان
    canvas.drawLine(const Offset(400, 266), const Offset(424, 264), s);

    // العينان: نقطة عادية، خط عند الرمش، ^ عند الابتسامة.
    final look = mode == AssistantAvatarMode.idle ? 4 * _wave(0.4, 0.5) : 0.0;
    for (final c in [Offset(190 + look, 286), Offset(342 + look, 286)]) {
      if (happy > 0.5) {
        final h = 12 * happy;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - 16, c.dy + h / 2)
            ..quadraticBezierTo(c.dx, c.dy - h * 1.4, c.dx + 16, c.dy + h / 2),
          _stroke(navy, 12),
        );
      } else if (blink > 0.5) {
        canvas.drawLine(Offset(c.dx - 16, c.dy), Offset(c.dx + 16, c.dy), _stroke(navy, 12));
      } else {
        final r = 14 * (1 - blink * 0.6) * (1 - happy);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 28, height: 2 * r),
          Paint()..color = navy,
        );
      }
    }
  }

  void _paintNoseAndMouth(Canvas canvas, bool speaking, bool listening) {
    final s = _stroke(navy, 18);
    // الأنف: قوس ثابت
    canvas.drawPath(
      Path()
        ..moveTo(216, 384)
        ..quadraticBezierTo(264, 362, 312, 382),
      s,
    );

    if (listening) {
      // فم "o" يتبع صوت المستخدم
      final w = 42 + 12 * level, h = 32 + 14 * level;
      canvas.drawOval(Rect.fromCenter(center: const Offset(264, 434), width: w, height: h), s);
      return;
    }
    // ابتسامة على شكل U تتسع مع ^^، وتنفتح أثناء الكلام.
    final half = 34 + 10 * happy;
    final y = 424 - 4 * happy;
    final l = Offset(264 - half, y), r = Offset(264 + half, y - 4);
    final bottom = 454 + 10 * happy;
    final o = open.clamp(0.0, 1.0);
    if (o < 0.05) {
      canvas.drawPath(
        Path()
          ..moveTo(l.dx, l.dy)
          ..quadraticBezierTo(264, bottom, r.dx, r.dy),
        s,
      );
      return;
    }
    // فم مفتوح: الشفة العليا شبه مستقيمة والسفلى تنزل بقدر الفتح.
    final mouth = Path()
      ..moveTo(l.dx, l.dy)
      ..quadraticBezierTo(264, y + 6 - 4 * o, r.dx, r.dy)
      ..quadraticBezierTo(264, bottom + 26 * o, l.dx, l.dy)
      ..close();
    canvas.drawPath(mouth, Paint()..color = navy);
    canvas.drawPath(mouth, s..strokeWidth = 14);
  }

  @override
  bool shouldRepaint(_AvatarPainter old) =>
      old.t != t ||
      old.open != open ||
      old.blink != blink ||
      old.happy != happy ||
      old.level != level ||
      old.mode != mode;
}
