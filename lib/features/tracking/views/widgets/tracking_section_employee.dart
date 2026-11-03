import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import 'add_manual_point_modal.dart';
import 'tracking_map_view_dialog.dart';
import 'tracking_session_card.dart';
import 'tracking_status_badge.dart';
import 'package:app_test/core/constants/app_design.dart';

class TrackingSectionEmployee extends StatefulWidget {
  final dynamic request;
  final bool isDateMatched;

  const TrackingSectionEmployee({
    super.key,
    required this.request,
    this.isDateMatched = true,
  });

  @override
  State<TrackingSectionEmployee> createState() => _TrackingSectionEmployeeState();
}

class _TrackingSectionEmployeeState extends State<TrackingSectionEmployee> {
  late RequestTrackingStatus _status;
  late List<TrackingSessionModel> _sessions;
  int _unuploadedCount = 3;

  @override
  void initState() {
    super.initState();
    _status = RequestTrackingStatus.active;
    _sessions = [
      TrackingDummyData.session1,
      TrackingDummyData.activeSession,
    ];
  }

  void _startTracking() {
    final bool isAr = LocalizationService.isArabic(context: context);
    setState(() {
      _status = RequestTrackingStatus.active;
      final newSession = TrackingSessionModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        requestId: 101,
        employeeId: 5,
        startedAt: DateTime.now(),
        status: TrackingSessionStatus.active,
        pointsCount: 1,
        points: [
          TrackingPointModel(
            clientPointId: 'pt-${DateTime.now().millisecondsSinceEpoch}',
            latitude: 30.0444,
            longitude: 31.2357,
            recordedAt: DateTime.now(),
            label: 'بداية جلسة جديدة',
            labelEn: 'New leg started',
            isStartPoint: true,
          ),
        ],
      );
      _sessions.add(newSession);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'تم بدء جلسة تتبع جديدة بنجاح 🚀'
              : 'New tracking session started successfully 🚀',
        ),
        backgroundColor: const Color(0xff2D6A4F),
      ),
    );
  }

  void _stopTracking() {
    final bool isAr = LocalizationService.isArabic(context: context);
    setState(() {
      _status = RequestTrackingStatus.completed;
      if (_sessions.isNotEmpty) {
        final last = _sessions.removeLast();
        _sessions.add(
          TrackingSessionModel(
            id: last.id,
            requestId: last.requestId,
            employeeId: last.employeeId,
            startedAt: last.startedAt,
            endedAt: DateTime.now(),
            status: TrackingSessionStatus.completed,
            stopSource: 'manual',
            pointsCount: last.pointsCount + 1,
            manualPointsCount: last.manualPointsCount,
            durationMinutes: DateTime.now().difference(last.startedAt).inMinutes,
            points: [
              ...last.points,
              TrackingPointModel(
                clientPointId: 'pt-${DateTime.now().millisecondsSinceEpoch}',
                latitude: 30.0610,
                longitude: 31.2480,
                recordedAt: DateTime.now(),
                label: 'نقطة التوقف اليدوي',
                labelEn: 'Manual stop point',
                isEndPoint: true,
              ),
            ],
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'تم إنهاء جلسة التتبع وحفظ المسار بنجاح 🏁'
              : 'Tracking session ended & route saved 🏁',
        ),
        backgroundColor: const Color(0xFF3389EE),
      ),
    );
  }

  void _addManualPoint() {
    final bool isAr = LocalizationService.isArabic(context: context);
    AddManualPointModal.show(
      context,
      onSubmit: (label) {
        setState(() {
          if (_sessions.isNotEmpty) {
            final last = _sessions.removeLast();
            final updatedPoints = List<TrackingPointModel>.from(last.points)
              ..add(
                TrackingPointModel(
                  clientPointId: 'pt-manual-${DateTime.now().millisecondsSinceEpoch}',
                  latitude: 30.0595 + (_sessions.length * 0.001),
                  longitude: 31.2465 + (_sessions.length * 0.001),
                  recordedAt: DateTime.now(),
                  pointType: 'manual',
                  label: label,
                  labelEn: label,
                ),
              );

            _sessions.add(
              TrackingSessionModel(
                id: last.id,
                requestId: last.requestId,
                employeeId: last.employeeId,
                startedAt: last.startedAt,
                endedAt: last.endedAt,
                status: last.status,
                pointsCount: last.pointsCount + 1,
                manualPointsCount: last.manualPointsCount + 1,
                durationMinutes: last.durationMinutes,
                points: updatedPoints,
              ),
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr ? 'تم تسجيل: "$label" بنجاح 📍' : 'Recorded: "$label" successfully 📍',
            ),
            backgroundColor: Color(AppColors.buttons),
          ),
        );
      },
    );
  }

  void _syncUnuploaded() {
    final bool isAr = LocalizationService.isArabic(context: context);
    setState(() => _unuploadedCount = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? 'تمت مزامنة ورفع جميع النقاط بنجاح ☁️'
              : 'All points synced & uploaded successfully ☁️',
        ),
        backgroundColor: const Color(0xff2D6A4F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);
    final bool isSessionActive = _status == RequestTrackingStatus.active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status & Overview Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(AppSizes.s16),
          decoration: ShapeDecoration(
            color: Color(AppColors.cardBackground), // 0xFFF1F6FF
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: Color(AppColors.border)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      children: [
                        Text(
                          isAr ? 'تتبع الموقع للمهمة' : 'Request Location Tracking',
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.titleText),
                          ),
                        ),
                        Text(
                          isAr
                              ? 'تتبع المسار الفعلي وتسجيل المحطات الرئيسية'
                              : 'Track actual route & record key milestones',
                          style: AppStyles.subtitleContent(context).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TrackingStatusBadge(status: _status),
                ],
              ),
              const SizedBox(height: 14),
              // Unuploaded sync banner
              if (_unuploadedCount > 0) ...[
                InkWell(
                  onTap: _syncUnuploaded,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(AppColors.warningYellow).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: Color(AppColors.warningYellow).withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sync_problem_rounded, size: 16, color: Color(AppColors.warningYellow)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAr
                                ? 'توجد $_unuploadedCount نقاط غير مرسلة (انقطاع اتصال)'
                                : '$_unuploadedCount unsent points (connection lost)',
                            style: AppStyles.content(context).copyWith(
                              fontSize: 11.5,
                              color: const Color(0xffAE702B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          isAr ? 'مزامنة الآن ⟳' : 'Sync Now ⟳',
                          style: AppStyles.content(context).copyWith(
                            fontSize: 11,
                            color: Color(AppColors.buttons),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Employee Action Buttons
              Row(
                children: [
                  if (!isSessionActive)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2D6A4F), // Green
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                          elevation: 0,
                        ),
                        onPressed: widget.isDateMatched ? _startTracking : null,
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                        label: Text(
                          widget.isDateMatched
                              ? (isAr ? 'بدء جلسة تتبع جديدة' : 'Start New Tracking Leg')
                              : (isAr ? 'التتبع متاح بتوقيت الطلب فقط' : 'Tracking only on request date'),
                          style: AppStyles.whiteContent(context).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.buttons),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                          elevation: 0,
                        ),
                        onPressed: _addManualPoint,
                        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 18),
                        label: Text(
                          isAr ? 'نقطة يدوية 📍' : 'Manual Point 📍',
                          style: AppStyles.whiteContent(context).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.failureRed),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                          elevation: 0,
                        ),
                        onPressed: _stopTracking,
                        icon: const Icon(Icons.stop_rounded, color: Colors.white, size: 18),
                        label: Text(
                          isAr ? 'إيقاف الجلسة ⏹' : 'Stop Leg ⏹',
                          style: AppStyles.whiteContent(context).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Sessions List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                isAr ? 'جلسات المسار (Legs)' : 'Route Sessions (Legs)',
                style: AppStyles.heading(context).copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.titleText),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(AppColors.secondaryButton).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${_sessions.length}',
                  style: TextStyle(
                    color: Color(AppColors.secondaryButton),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (_sessions.isNotEmpty)
                TextButton.icon(
                  onPressed: () => TrackingMapViewDialog.show(
                    context,
                    title: isAr ? 'خريطة المسار الكامل للطلب' : 'Full Request Route Map',
                    titleEn: 'Full Request Route Map',
                    sessions: _sessions,
                  ),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: Text(
                    isAr ? 'الخريطة الكاملة' : 'Full Map',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),

        // List of Session Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sessions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(AppColors.cardBackground),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    isAr
                        ? 'لم يتم بدء أي جلسة تتبع بعد على هذا الطلب'
                        : 'No tracking sessions recorded yet for this request',
                    style: AppStyles.hintContent(context).copyWith(fontSize: 12),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final s = _sessions[index];
                    return TrackingSessionCard(
                      session: s,
                      sessionIndex: index,
                      onOpenMap: () => TrackingMapViewDialog.show(
                        context,
                        title: isAr ? 'مسار جلسة #${index + 1}' : 'Route for Session #${index + 1}',
                        titleEn: 'Route for Session #${index + 1}',
                        sessions: [s],
                        initialSessionId: s.id,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
