import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/employee_tracking_summary.model.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/models/tracking_status.enum.dart';
import '../widgets/manual_point_tile.dart';
import '../widgets/tracking_status_badge.dart';
import 'package:app_test/core/constants/app_design.dart';

enum MapTimeFilter {
  live,
  today,
  customDate;

  String getLabel({bool isArabic = true}) {
    switch (this) {
      case MapTimeFilter.live:
        return 'live_now'.tr();
      case MapTimeFilter.today:
        return 'today'.tr();
      case MapTimeFilter.customDate:
        return 'custom_date'.tr();
    }
  }
}

class LiveGroupMapScreen extends StatefulWidget {
  const LiveGroupMapScreen({super.key});

  @override
  State<LiveGroupMapScreen> createState() => _LiveGroupMapScreenState();
}

class _LiveGroupMapScreenState extends State<LiveGroupMapScreen> {
  MapTimeFilter _timeFilter = MapTimeFilter.live;
  DateTime _selectedDate = DateTime.now();
  int _currentPage = 1;
  static const int _perPage = 10;

  late List<EmployeeTrackingSummaryModel> _employees;
  EmployeeTrackingSummaryModel? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    _employees = List.from(TrackingDummyData.dummyEmployees);
    if (_employees.isNotEmpty) {
      _selectedEmployee = _employees.first;
    }
  }

  void _onRefresh() {
    setState(() {
      _employees = List.from(TrackingDummyData.dummyEmployees);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('employee_locations_updated_live'.tr(),
        ),
        backgroundColor: const Color(0xFF3389EE),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(AppColors.buttons),
            colorScheme: ColorScheme.light(primary: Color(AppColors.buttons)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _timeFilter = MapTimeFilter.customDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);
    final activeCount = _employees.where((e) => e.isActive).length;

    return Scaffold(
      backgroundColor: Color(AppColors.scaffoldBackGround), // 0xFFF5F8FA
      body: Column(
        children: [
          // ── Header AppBar (Matching TeamMind Curved Header) ──
          Container(
            decoration: BoxDecoration(
              color: Color(AppColors.secondaryButton), // 0xFF090B60
              image: const DecorationImage(
                image: AssetImage('assets/images/request-app-bar.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App Bar Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('field_team_live_tracking_map'.tr(),
                                style: AppStyles.whiteHeading(context).copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('active_staff_10_shown'.tr(namedArgs: {'active_count': '$activeCount'}),
                                style: AppStyles.whiteContent(context).copyWith(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'refresh_locations'.tr(),
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                          onPressed: _onRefresh,
                        ),
                      ],
                    ),
                  ),

                  // Segment Toggle (الآن / اليوم / تاريخ محدد)
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        _FilterTabItem(
                          label: MapTimeFilter.live.getLabel(isArabic: isAr),
                          isActive: _timeFilter == MapTimeFilter.live,
                          onTap: () => setState(() => _timeFilter = MapTimeFilter.live),
                        ),
                        _FilterTabItem(
                          label: MapTimeFilter.today.getLabel(isArabic: isAr),
                          isActive: _timeFilter == MapTimeFilter.today,
                          onTap: () => setState(() => _timeFilter = MapTimeFilter.today),
                        ),
                        _FilterTabItem(
                          label: MapTimeFilter.customDate.getLabel(isArabic: isAr),
                          isActive: _timeFilter == MapTimeFilter.customDate,
                          onTap: _pickCustomDate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Horizontal Employee Chips ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _employees.map((emp) {
                  final isSelected = _selectedEmployee?.employeeId == emp.employeeId;
                  final empColor = TrackingDummyData.getEmployeeColor(emp.colorIndex);

                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedEmployee = emp),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? empColor.withOpacity(0.12) : Color(AppColors.cardBackground),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: isSelected ? empColor : Color(AppColors.border),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: empColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              emp.getName(isArabic: isAr),
                              style: AppStyles.content(context).copyWith(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? empColor : Color(AppColors.bodyText),
                              ),
                            ),
                            if (emp.isActive) ...[
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xff2D6A4F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Interactive Map View ──
          Expanded(
            child: Stack(
              children: [
                // Canvas Visualizer
                Positioned.fill(
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(80),
                    minScale: 0.4,
                    maxScale: 5.0,
                    child: CustomPaint(
                      painter: _GroupLiveMapPainter(
                        employees: _employees,
                        selectedEmployeeId: _selectedEmployee?.employeeId,
                        isArabic: isAr,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),

                // Palette Guide Pill
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.palette_outlined, size: 14, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text('dynamic_palette_staff'.tr(namedArgs: {'length': '${_employees.length}'}),
                          style: AppStyles.content(context).copyWith(fontSize: 10.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Selected Employee Summary Card ──
          if (_selectedEmployee != null)
            _EmployeeDetailsCard(
              employee: _selectedEmployee!,
              color: TrackingDummyData.getEmployeeColor(_selectedEmployee!.colorIndex),
              isArabic: isAr,
            ),

          // ── Pagination Footer ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(AppColors.border))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('page_of_2_18_employees_total'.tr(namedArgs: {'current_page': '$_currentPage'}),
                  style: AppStyles.subtitleContent(context).copyWith(fontSize: 11.5),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      color: Color(AppColors.buttons),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(AppColors.buttons).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        '$_currentPage',
                        style: TextStyle(
                          color: Color(AppColors.buttons),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      onPressed: _currentPage < 2 ? () => setState(() => _currentPage++) : null,
                      color: Color(AppColors.buttons),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? Color(AppColors.buttons) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _EmployeeDetailsCard extends StatefulWidget {
  final EmployeeTrackingSummaryModel employee;
  final Color color;
  final bool isArabic;

  const _EmployeeDetailsCard({
    required this.employee,
    required this.color,
    this.isArabic = true,
  });

  @override
  State<_EmployeeDetailsCard> createState() => _EmployeeDetailsCardState();
}

class _EmployeeDetailsCardState extends State<_EmployeeDetailsCard> {
  bool _showTimeline = false;

  @override
  Widget build(BuildContext context) {
    final emp = widget.employee;
    final isAr = widget.isArabic;
    final activeSess = emp.activeSession;
    final keyPoints = activeSess?.manualPoints ?? [];
    final empName = emp.getName(isArabic: isAr);

    return Container(
      constraints: BoxConstraints(maxHeight: _showTimeline ? 260 : 130),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: widget.color.withOpacity(0.5), width: 1.5),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: widget.color,
                child: Text(
                  empName.isNotEmpty ? empName[0] : ('e'.tr()),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          empName,
                          style: AppStyles.content(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.titleText),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TrackingStatusBadge(
                          status: emp.isActive
                              ? RequestTrackingStatus.active
                              : (emp.status == 'completed'
                                  ? RequestTrackingStatus.completed
                                  : RequestTrackingStatus.optionalNotStarted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${emp.getDepartment(isArabic: isAr)} • ${emp.getLastUpdatedText(isArabic: isAr)}',
                      style: AppStyles.subtitleContent(context).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (keyPoints.isNotEmpty)
                IconButton(
                  tooltip: _showTimeline
                      ? ('hide_points'.tr())
                      : ('show_milestones'.tr()),
                  icon: Icon(_showTimeline ? Icons.keyboard_arrow_down : Icons.timeline, color: widget.color),
                  onPressed: () => setState(() => _showTimeline = !_showTimeline),
                ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(color: Color(AppColors.divider), height: 1),
          const SizedBox(height: 8),

          // Last point or Session status
          if (emp.lastPoint != null)
            Row(
              children: [
                Icon(Icons.pin_drop_rounded, size: 14, color: widget.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    emp.lastPoint!.getDisplayLabel(isArabic: isAr),
                    style: AppStyles.content(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Text('no_active_tracking_session_recorded_currently_for'.tr(),
              style: AppStyles.hintContent(context).copyWith(fontSize: 11.5),
            ),

          // Optional Expanded Timeline
          if (_showTimeline && keyPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: keyPoints.length,
                itemBuilder: (context, idx) {
                  return ManualPointTile(
                    point: keyPoints[idx],
                    isLast: idx == keyPoints.length - 1,
                    isArabic: isAr,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupLiveMapPainter extends CustomPainter {
  final List<EmployeeTrackingSummaryModel> employees;
  final int? selectedEmployeeId;
  final bool isArabic;

  _GroupLiveMapPainter({
    required this.employees,
    this.selectedEmployeeId,
    this.isArabic = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFE8EEF5)
      ..strokeWidth = 1.0;

    const gridSize = 32.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Gather all points
    final allPoints = <TrackingPointModel>[];
    for (final emp in employees) {
      if (emp.lastPoint != null) allPoints.add(emp.lastPoint!);
      for (final s in emp.sessions) {
        allPoints.addAll(s.points);
      }
    }

    if (allPoints.isEmpty) return;

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

    const margin = 55.0;
    final usableW = size.width - margin * 2;
    final usableH = size.height - margin * 2;

    Offset toCanvas(double lat, double lng) {
      final x = margin + ((lng - minLng) / lngRange) * usableW;
      final y = size.height - margin - ((lat - minLat) / latRange) * usableH;
      return Offset(x, y);
    }

    // 3. Draw routes for each employee
    for (final emp in employees) {
      final empColor = TrackingDummyData.getEmployeeColor(emp.colorIndex);
      final isSel = selectedEmployeeId == emp.employeeId;

      for (final s in emp.sessions) {
        if (s.points.length < 2) continue;

        final linePaint = Paint()
          ..color = empColor.withOpacity(isSel ? 0.95 : 0.6)
          ..strokeWidth = isSel ? 4.5 : 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final path = Path();
        for (int i = 0; i < s.points.length; i++) {
          final pt = toCanvas(s.points[i].latitude, s.points[i].longitude);
          if (i == 0) {
            path.moveTo(pt.dx, pt.dy);
          } else {
            path.lineTo(pt.dx, pt.dy);
          }
        }
        canvas.drawPath(path, linePaint);
      }
    }

    // 4. Draw employee live markers (pins with initials and pulsing ring)
    for (final emp in employees) {
      if (emp.lastPoint == null) continue;

      final pt = toCanvas(emp.lastPoint!.latitude, emp.lastPoint!.longitude);
      final empColor = TrackingDummyData.getEmployeeColor(emp.colorIndex);
      final isSel = selectedEmployeeId == emp.employeeId;

      // Pulse ring for active or selected
      if (isSel || emp.isActive) {
        canvas.drawCircle(pt, isSel ? 20 : 14, Paint()..color = empColor.withOpacity(0.2));
      }

      // Outer pin circle
      canvas.drawCircle(
        pt,
        isSel ? 12 : 9,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        pt,
        isSel ? 12 : 9,
        Paint()
          ..color = empColor
          ..strokeWidth = isSel ? 3.0 : 2.0
          ..style = PaintingStyle.stroke,
      );
      canvas.drawCircle(pt, isSel ? 8 : 6, Paint()..color = empColor);

      // Name label
      final empDisplayName = emp.getName(isArabic: isArabic);
      final tp = TextPainter(
        text: TextSpan(
          text: empDisplayName,
          style: TextStyle(
            color: isSel ? empColor : Colors.black87,
            fontSize: isSel ? 11 : 9.5,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
            backgroundColor: Colors.white.withOpacity(0.85),
          ),
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pt.dx - tp.width / 2, pt.dy - (isSel ? 28 : 23)));
    }
  }

  @override
  bool shouldRepaint(covariant _GroupLiveMapPainter oldDelegate) => true;
}
