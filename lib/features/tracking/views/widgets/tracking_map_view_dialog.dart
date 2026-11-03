import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/models/tracking_session.model.dart';
import 'package:app_test/core/constants/app_design.dart';

class TrackingMapViewDialog extends StatefulWidget {
  final String title;
  final String? titleEn;
  final List<TrackingSessionModel> sessions;
  final int? initialSessionId;

  const TrackingMapViewDialog({
    super.key,
    required this.title,
    this.titleEn,
    required this.sessions,
    this.initialSessionId,
  });

  static void show(
    BuildContext context, {
    required String title,
    String? titleEn,
    required List<TrackingSessionModel> sessions,
    int? initialSessionId,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => TrackingMapViewDialog(
        title: title,
        titleEn: titleEn,
        sessions: sessions,
        initialSessionId: initialSessionId,
      ),
    );
  }

  @override
  State<TrackingMapViewDialog> createState() => _TrackingMapViewDialogState();
}

class _TrackingMapViewDialogState extends State<TrackingMapViewDialog> {
  int? _selectedSessionId;
  TrackingPointModel? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedSessionId = widget.initialSessionId;
  }

  List<TrackingSessionModel> get _displayedSessions {
    if (_selectedSessionId == null) return widget.sessions;
    return widget.sessions.where((s) => s.id == _selectedSessionId).toList();
  }

  List<TrackingPointModel> get _allPoints {
    final list = <TrackingPointModel>[];
    for (final s in _displayedSessions) {
      list.addAll(s.points);
    }
    return list;
  }

  Future<void> _openInExternalMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);
    final displayTitle = isAr ? widget.title : (widget.titleEn ?? widget.title);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: 550,
          height: 600,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: Color(AppColors.secondaryButton), // 0xFF090B60
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: AppStyles.whiteHeading(context).copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isAr
                                ? '${widget.sessions.length} جلسات • ${_allPoints.length} نقطة مسجلة'
                                : '${widget.sessions.length} legs • ${_allPoints.length} points recorded',
                            style: AppStyles.whiteContent(context).copyWith(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Session filter chips
              if (widget.sessions.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Color(AppColors.cardBackground),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(isAr ? 'كل المسارات (مجمعة)' : 'All Legs (Merged)'),
                          selected: _selectedSessionId == null,
                          selectedColor: Color(AppColors.buttons),
                          labelStyle: TextStyle(
                            color: _selectedSessionId == null ? Colors.white : Color(AppColors.bodyText),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => _selectedSessionId = null),
                        ),
                        ...widget.sessions.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final s = entry.value;
                          final isSel = _selectedSessionId == s.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                isAr
                                    ? 'جلسة #${idx + 1} (${s.getDurationFormatted(isArabic: isAr)})'
                                    : 'Leg #${idx + 1} (${s.getDurationFormatted(isArabic: isAr)})',
                              ),
                              selected: isSel,
                              selectedColor: Color(AppColors.buttons),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : Color(AppColors.bodyText),
                                fontSize: 11,
                              ),
                              onSelected: (_) => setState(() => _selectedSessionId = s.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // Canvas Map Area
              Expanded(
                child: Stack(
                  children: [
                    // Interactive Canvas
                    Positioned.fill(
                      child: InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(50),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: CustomPaint(
                          painter: _RouteMapPainter(
                            sessions: _displayedSessions,
                            selectedPoint: _selectedPoint,
                            isArabic: isAr,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),

                    // Controls Overlay
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app_outlined, size: 14, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              isAr
                                  ? 'اسحب وحرّك للتكبير والتحكم في المسار'
                                  : 'Pinch & drag to zoom and pan route',
                              style: AppStyles.content(context).copyWith(fontSize: 10, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Selected Point Info Card
                    if (_selectedPoint != null)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(AppColors.buttons).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.location_on, color: Color(AppColors.buttons), size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedPoint!.getDisplayLabel(isArabic: isAr),
                                      style: AppStyles.content(context).copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      isAr
                                          ? '${_selectedPoint!.latitude.toStringAsFixed(5)}, ${_selectedPoint!.longitude.toStringAsFixed(5)} • دقة: ${_selectedPoint!.accuracy}م'
                                          : '${_selectedPoint!.latitude.toStringAsFixed(5)}, ${_selectedPoint!.longitude.toStringAsFixed(5)} • Acc: ${_selectedPoint!.accuracy}m',
                                      style: AppStyles.hintContent(context).copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: isAr ? 'فتح في Google Maps' : 'Open in Google Maps',
                                icon: const Icon(Icons.open_in_new, size: 18),
                                color: Color(AppColors.buttons),
                                onPressed: () => _openInExternalMaps(
                                  _selectedPoint!.latitude,
                                  _selectedPoint!.longitude,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: Colors.grey,
                                onPressed: () => setState(() => _selectedPoint = null),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Legend
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(AppColors.border))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _LegendItem(
                      color: const Color(0xff2D6A4F),
                      label: isAr ? 'نقطة الانطلاق' : 'Start Point',
                    ),
                    _LegendItem(
                      color: Color(AppColors.buttons),
                      label: isAr ? 'نقطة رئيسية 📍' : 'Milestone 📍',
                    ),
                    _LegendItem(
                      color: const Color(0xffc72c41),
                      label: isAr ? 'نقطة التوقف' : 'End Point',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppStyles.content(context).copyWith(fontSize: 11, color: const Color(0xff606060)),
        ),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final List<TrackingSessionModel> sessions;
  final TrackingPointModel? selectedPoint;
  final bool isArabic;

  _RouteMapPainter({
    required this.sessions,
    this.selectedPoint,
    this.isArabic = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle grid background
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F6FF)
      ..strokeWidth = 1.0;

    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Collect all points to normalize coordinates to canvas
    final allPoints = <TrackingPointModel>[];
    for (final s in sessions) {
      allPoints.addAll(s.points);
    }

    if (allPoints.isEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: isArabic ? 'لا توجد إحداثيات مسجلة لعرضها' : 'No coordinates recorded to display',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
      );
      return;
    }

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = (maxLat - minLat).abs() > 0.0001 ? (maxLat - minLat) : 0.01;
    final lngRange = (maxLng - minLng).abs() > 0.0001 ? (maxLng - minLng) : 0.01;

    const margin = 50.0;
    final usableW = size.width - margin * 2;
    final usableH = size.height - margin * 2;

    Offset toCanvas(double lat, double lng) {
      final x = margin + ((lng - minLng) / lngRange) * usableW;
      final y = size.height - margin - ((lat - minLat) / latRange) * usableH;
      return Offset(x, y);
    }

    // Draw route lines for each session
    for (int sIdx = 0; sIdx < sessions.length; sIdx++) {
      final session = sessions[sIdx];
      if (session.points.length < 2) continue;

      final sessionColor = TrackingDummyData.getEmployeeColor(sIdx);
      final linePaint = Paint()
        ..color = sessionColor.withOpacity(0.85)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final shadowPaint = Paint()
        ..color = sessionColor.withOpacity(0.2)
        ..strokeWidth = 7.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < session.points.length; i++) {
        final pt = toCanvas(session.points[i].latitude, session.points[i].longitude);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, linePaint);
    }

    // Draw point markers
    for (final s in sessions) {
      for (final p in s.points) {
        final pt = toCanvas(p.latitude, p.longitude);

        if (p.isStartPoint) {
          _drawPin(canvas, pt, const Color(0xff2D6A4F), isArabic ? 'البداية' : 'Start');
        } else if (p.isEndPoint) {
          _drawPin(canvas, pt, const Color(0xffc72c41), isArabic ? 'النهاية' : 'End');
        } else if (p.isManual) {
          _drawPin(canvas, pt, const Color(0xFF3389EE), p.getDisplayLabel(isArabic: isArabic));
        } else {
          final dotPaint = Paint()..color = const Color(0xFF3389EE).withOpacity(0.6);
          canvas.drawCircle(pt, 3.5, dotPaint);
        }
      }
    }
  }

  void _drawPin(Canvas canvas, Offset offset, Color color, String label) {
    canvas.drawCircle(offset, 12, Paint()..color = color.withOpacity(0.2));

    canvas.drawCircle(
      offset,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      offset,
      8,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(offset, 4, Paint()..color = color);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.85),
        ),
      ),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(offset.dx - tp.width / 2, offset.dy - 22));
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) => true;
}
