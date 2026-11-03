import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_session.model.dart';
import '../../data/models/tracking_status.enum.dart';
import 'cancel_tracking_modal.dart';
import 'tracking_map_view_dialog.dart';
import 'tracking_session_card.dart';
import 'tracking_status_badge.dart';
import 'package:app_test/core/constants/app_design.dart';

class TrackingSectionManager extends StatefulWidget {
  final dynamic request;
  final bool isAdmin;

  const TrackingSectionManager({
    super.key,
    required this.request,
    this.isAdmin = true,
  });

  @override
  State<TrackingSectionManager> createState() => _TrackingSectionManagerState();
}

class _TrackingSectionManagerState extends State<TrackingSectionManager> {
  RequestTrackingStatus _status = RequestTrackingStatus.active;
  List<TrackingSessionModel> _sessions = [
    TrackingDummyData.session1,
    TrackingDummyData.activeSession,
  ];

  double _activeHours = 4.0;
  int _startStopCount = 3;
  double _hoursWithinWork = 3.5;

  void _onCancelTracking(String scope) {
    final bool isAr = LocalizationService.isArabic(context: context);
    setState(() {
      if (scope == 'current_session') {
        _sessions.removeWhere((s) => s.isActive);
        _status = RequestTrackingStatus.completed;
      } else {
        _sessions.clear();
        _status = RequestTrackingStatus.optionalNotStarted;
        _activeHours = 0;
        _startStopCount = 0;
        _hoursWithinWork = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          scope == 'current_session'
              ? (isAr ? 'تم إلغاء الجلسة الحالية بنجاح ⚠️' : 'Current leg cancelled successfully ⚠️')
              : (isAr ? 'تم إلغاء كل بيانات التتبع للطلب 🚫' : 'All tracking data voided for request 🚫'),
        ),
        backgroundColor: Color(AppColors.failureRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = LocalizationService.isArabic(context: context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Manager Stats Overview Card
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
                      color: Color(AppColors.secondaryButton).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.analytics_outlined, color: Color(AppColors.secondaryButton), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مؤشرات الامتثال والتتبع' : 'Compliance & Tracking Metrics',
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.titleText),
                          ),
                        ),
                        Text(
                          isAr
                              ? 'تحليل ساعات النشاط الفعلي وفترات الحركة'
                              : 'Actual active hours & movement analysis',
                          style: AppStyles.subtitleContent(context).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TrackingStatusBadge(status: _status),
                ],
              ),
              const SizedBox(height: 14),

              // 3 KPI Info Tiles
              Row(
                children: [
                  Expanded(
                    child: _ManagerKpiTile(
                      icon: Icons.timer_outlined,
                      label: isAr ? 'ساعات النشاط' : 'Active Hours',
                      value: isAr ? '$_activeHours س' : '${_activeHours}h',
                      color: Color(AppColors.buttons),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ManagerKpiTile(
                      icon: Icons.repeat_rounded,
                      label: isAr ? 'مرات البدء (Legs)' : 'Legs Count',
                      value: isAr ? '$_startStopCount مرات' : '$_startStopCount legs',
                      color: const Color(0xff2D6A4F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ManagerKpiTile(
                      icon: Icons.access_time_filled_outlined,
                      label: isAr ? 'داخل وقت الدوام' : 'In Work Hours',
                      value: isAr ? '$_hoursWithinWork س' : '${_hoursWithinWork}h',
                      color: const Color(0xffAE702B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Route Map CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.buttons),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    elevation: 0,
                  ),
                  onPressed: _sessions.isEmpty
                      ? null
                      : () => TrackingMapViewDialog.show(
                            context,
                            title: isAr ? 'خريطة المسار الكامل للمهمة' : 'Full Request Route Map',
                            titleEn: 'Full Request Route Map',
                            sessions: _sessions,
                          ),
                  icon: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                  label: Text(
                    isAr ? 'عرض المسار الكامل على الخريطة 🗺️' : 'View Full Route on Map 🗺️',
                    style: AppStyles.whiteContent(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              // Admin Cancel Button
              if (widget.isAdmin && _sessions.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(AppColors.failureRed),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => CancelTrackingModal.show(
                      context,
                      onConfirm: _onCancelTracking,
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: Text(
                      isAr ? 'إلغاء التتبع إداريًا (Admin)' : 'Cancel Tracking as Admin',
                      style: AppStyles.content(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.failureRed),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Session list header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            isAr ? 'سجل الجلسات والمحطات المسجلة للموظف' : 'Recorded Legs & Milestone History',
            style: AppStyles.heading(context).copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.titleText),
            ),
          ),
        ),

        // Sessions list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sessions.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(AppColors.cardBackground),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    isAr ? 'لا توجد جلسات تتبع مسجلة لهذا الطلب' : 'No tracking legs recorded for this request',
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

class _ManagerKpiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ManagerKpiTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Color(AppColors.border)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.content(context).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.titleText),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppStyles.hintContent(context).copyWith(
              fontSize: 10,
              color: const Color(0xff606060),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
