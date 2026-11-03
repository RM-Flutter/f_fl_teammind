import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
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
              ? ('current_leg_cancelled_successfully'.tr())
              : ('all_tracking_data_voided_for_request'.tr()),
        ),
        backgroundColor: Color(AppColors.failureRed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

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
                        Text('compliance_tracking_metrics'.tr(),
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.titleText),
                          ),
                        ),
                        Text('actual_active_hours_movement_analysis'.tr(),
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
                      label: 'active_hours'.tr(),
                      value: 'h'.tr(namedArgs: {'active_hours': '$_activeHours'}),
                      color: Color(AppColors.buttons),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ManagerKpiTile(
                      icon: Icons.repeat_rounded,
                      label: 'legs_count'.tr(),
                      value: 'legs'.tr(namedArgs: {'start_stop_count': '$_startStopCount'}),
                      color: const Color(0xff2D6A4F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ManagerKpiTile(
                      icon: Icons.access_time_filled_outlined,
                      label: 'in_work_hours'.tr(),
                      value: 'h_2'.tr(namedArgs: {'hours_within_work': '$_hoursWithinWork'}),
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
                            title: 'full_request_route_map_2'.tr(),
                            titleEn: 'Full Request Route Map',
                            sessions: _sessions,
                          ),
                  icon: const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                  label: Text('view_full_route_on_map'.tr(),
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
                    label: Text('cancel_tracking_as_admin'.tr(),
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
          child: Text('recorded_legs_milestone_history'.tr(),
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
                  child: Text('no_tracking_legs_recorded_for_this_request'.tr(),
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
                        title: 'route_for_session'.tr(namedArgs: {'index_1': '${index + 1}'}),
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
