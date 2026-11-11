import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/services/localization_service.dart';
import '../../data/models/tracking_point.model.dart';

/// The 10 route colours of the group map. Spec: one page shows at most 10 employees, and each one
/// takes the colour of their position on the page (not a colour stored per employee), so colours
/// never repeat on one page. Legs of one request use the same list.
abstract class TrackingPalette {
  static const List<Color> colors = [
    Color(0xFF3389EE), // blue
    Color(0xFF2D9D6B), // green
    Color(0xFFF08A24), // orange
    Color(0xFF9C4995), // purple
    Color(0xFF16A6C9), // cyan
    Color(0xFF2C376C), // navy
    Color(0xFFD9434F), // red
    Color(0xFFAE702B), // brown
    Color(0xFFE05EA0), // pink
    Color(0xFF6B7A2E), // olive
  ];

  static Color colorAt(int index) => colors[index % colors.length];
}

/// One route drawn on [TrackingRouteMap]: the points of one session / one employee in one colour.
class TrackingRouteLine {
  final Color color;
  final List<TrackingPointModel> points;

  /// Short text shown next to the current-position marker (employee name on the group map).
  final String? liveLabel;

  /// Draw the last point as the employee's current position (live mode).
  final bool showLivePosition;

  /// Lines that are not selected are drawn faded when another one is selected.
  final bool dimmed;

  const TrackingRouteLine({
    required this.color,
    required this.points,
    this.liveLabel,
    this.showLivePosition = false,
    this.dimmed = false,
  });
}

/// The map of tracking routes used by the request route dialog and the group map.
///
/// There is no map SDK in the app yet, so the routes are drawn to scale on a light street-like
/// background; pinch to zoom, drag to pan, tap a start / end / manual point to select it.
/// Start points are green, end points red, manual points use the route colour and show their
/// title, auto points are small dots.
class TrackingRouteMap extends StatelessWidget {
  final List<TrackingRouteLine> lines;
  final TrackingPointModel? selectedPoint;
  final ValueChanged<TrackingPointModel>? onPointTap;
  final bool showAutoPoints;

  const TrackingRouteMap({
    super.key,
    required this.lines,
    this.selectedPoint,
    this.onPointTap,
    this.showAutoPoints = true,
  });

  static bool _isKey(TrackingPointModel p) => p.isStartPoint || p.isEndPoint || p.isManual;

  @override
  Widget build(BuildContext context) {
    final isAr = LocalizationService.isArabic(context: context);
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final projection = _Projection.of(lines, size);
      return ClipRect(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          boundaryMargin: const EdgeInsets.all(80),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onPointTap == null || projection == null
                ? null
                : (d) {
                    TrackingPointModel? best;
                    var bestDist = 26.0;
                    for (final line in lines) {
                      for (final p in line.points.where(_isKey)) {
                        final dist = (projection.toCanvas(p) - d.localPosition).distance;
                        if (dist < bestDist) {
                          bestDist = dist;
                          best = p;
                        }
                      }
                    }
                    if (best != null) onPointTap!(best);
                  },
            child: CustomPaint(
              size: size,
              painter: _RouteMapPainter(
                lines: lines,
                projection: projection,
                selectedPoint: selectedPoint,
                showAutoPoints: showAutoPoints,
                isArabic: isAr,
                emptyText: 'no_coordinates_recorded_to_display'.tr(),
                startText: 'start'.tr(),
                endText: 'end'.tr(),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Maps latitude / longitude to canvas offsets, keeping a margin around the routes.
class _Projection {
  final double minLat, minLng, latRange, lngRange;
  final Size size;
  static const double margin = 44;

  _Projection(this.minLat, this.minLng, this.latRange, this.lngRange, this.size);

  static _Projection? of(List<TrackingRouteLine> lines, Size size) {
    final pts = [for (final l in lines) ...l.points];
    if (pts.isEmpty || !size.width.isFinite || !size.height.isFinite) return null;
    var minLat = pts.first.latitude, maxLat = minLat;
    var minLng = pts.first.longitude, maxLng = minLng;
    for (final p in pts) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    var latRange = maxLat - minLat;
    var lngRange = maxLng - minLng;
    // A single point (or a straight line) still gets a sensible area around it.
    if (latRange < 0.002) {
      minLat -= 0.001;
      latRange = 0.002;
    }
    if (lngRange < 0.002) {
      minLng -= 0.001;
      lngRange = 0.002;
    }
    return _Projection(minLat, minLng, latRange, lngRange, size);
  }

  Offset toCanvas(TrackingPointModel p) {
    final w = size.width - margin * 2;
    final h = size.height - margin * 2;
    // Keep the aspect ratio so the route shape is not stretched.
    final scale = math.min(w / lngRange, h / latRange);
    final dx = (w - lngRange * scale) / 2;
    final dy = (h - latRange * scale) / 2;
    return Offset(
      margin + dx + (p.longitude - minLng) * scale,
      size.height - margin - dy - (p.latitude - minLat) * scale,
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final List<TrackingRouteLine> lines;
  final _Projection? projection;
  final TrackingPointModel? selectedPoint;
  final bool showAutoPoints;
  final bool isArabic;
  final String emptyText, startText, endText;

  _RouteMapPainter({
    required this.lines,
    required this.projection,
    required this.selectedPoint,
    required this.showAutoPoints,
    required this.isArabic,
    required this.emptyText,
    required this.startText,
    required this.endText,
  });

  static const _land = Color(0xFFF3F5FA);
  static const _block = Color(0xFFE9EDF5);
  static const _road = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    final proj = projection;
    if (proj == null) {
      _text(canvas, emptyText, Offset(size.width / 2, size.height / 2),
          const Color(0xFF8A8FA3), 13, center: true);
      return;
    }

    // Routes.
    for (final line in lines) {
      if (line.points.length < 2) continue;
      final alpha = line.dimmed ? 0.25 : 1.0;
      final path = Path();
      for (var i = 0; i < line.points.length; i++) {
        final o = proj.toCanvas(line.points[i]);
        i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = line.color.withValues(alpha: 0.18 * alpha)
            ..strokeWidth = 9
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
      canvas.drawPath(
          path,
          Paint()
            ..color = line.color.withValues(alpha: 0.9 * alpha)
            ..strokeWidth = 3.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }

    // Points.
    final green = Color(AppColors.successGreen);
    final red = Color(AppColors.failureRed);
    for (final line in lines) {
      final alpha = line.dimmed ? 0.3 : 1.0;
      for (final p in line.points) {
        final o = proj.toCanvas(p);
        if (p.isStartPoint) {
          _pin(canvas, o, green.withValues(alpha: alpha), startText, selected: p == selectedPoint);
        } else if (p.isEndPoint) {
          _pin(canvas, o, red.withValues(alpha: alpha), endText, selected: p == selectedPoint);
        } else if (p.isManual) {
          _pin(canvas, o, line.color.withValues(alpha: alpha), p.getDisplayLabel(isArabic: isArabic),
              selected: p == selectedPoint);
        } else if (showAutoPoints) {
          canvas.drawCircle(o, 2.6, Paint()..color = line.color.withValues(alpha: 0.55 * alpha));
        }
      }
      if (line.showLivePosition && line.points.isNotEmpty) {
        _livePosition(canvas, proj.toCanvas(line.points.last), line.color, line.liveLabel);
      }
    }
  }

  /// Soft "city" background: blocks between a few roads, so the canvas reads as a map.
  void _paintBackground(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _land);
    final blockPaint = Paint()..color = _block;
    const step = 68.0;
    for (double x = 10; x < size.width; x += step) {
      for (double y = 10; y < size.height; y += step) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, step - 18, step - 18), const Radius.circular(6)),
          blockPaint,
        );
      }
    }
    final road = Paint()
      ..color = _road
      ..strokeWidth = 7;
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.38), road);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.42, size.height), road);
  }

  void _pin(Canvas canvas, Offset o, Color color, String label, {bool selected = false}) {
    if (selected) canvas.drawCircle(o, 16, Paint()..color = color.withValues(alpha: 0.22));
    canvas.drawCircle(o, 8, Paint()..color = Colors.white);
    canvas.drawCircle(
        o,
        8,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.drawCircle(o, 3.5, Paint()..color = color);
    _chip(canvas, label, o.translate(0, -20), color);
  }

  void _livePosition(Canvas canvas, Offset o, Color color, String? label) {
    canvas.drawCircle(o, 15, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(o, 9, Paint()..color = Colors.white);
    canvas.drawCircle(o, 6.5, Paint()..color = color);
    if (label != null && label.isNotEmpty) _chip(canvas, label, o.translate(0, -22), color, strong: true);
  }

  /// A small white label with a coloured border, centred above a marker.
  void _chip(Canvas canvas, String text, Offset anchor, Color color, {bool strong = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 9.5, fontWeight: strong ? FontWeight.w700 : FontWeight.w600),
      ),
      maxLines: 1,
      ellipsis: '…',
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout(maxWidth: 130);
    final rect = Rect.fromCenter(center: anchor, width: tp.width + 12, height: tp.height + 6);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(AppRadius.pill));
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(
        rrect,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    tp.paint(canvas, Offset(rect.left + 6, rect.top + 3));
  }

  void _text(Canvas canvas, String text, Offset at, Color color, double size, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size)),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at - Offset(tp.width / 2, tp.height / 2) : at);
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter old) =>
      old.lines != lines || old.selectedPoint != selectedPoint || old.projection?.size != projection?.size;
}
