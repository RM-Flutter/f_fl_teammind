import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../data/models/tracking_point.model.dart';
import '../../data/models/tracking_session.model.dart';
import 'tracking_choice_chip.dart';
import 'tracking_route_map.dart';

/// Pop-up map of a request's route: every leg in its own colour, joined in time order, or one leg
/// on its own. Tap a start / end / manual point to see it and open it in Google Maps.
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
    _selectedSessionId = widget.sessions.length > 1 ? widget.initialSessionId : null;
  }

  List<TrackingRouteLine> get _lines => [
        for (var i = 0; i < widget.sessions.length; i++)
          if (_selectedSessionId == null || widget.sessions[i].id == _selectedSessionId)
            TrackingRouteLine(color: TrackingPalette.colorAt(i), points: widget.sessions[i].points),
      ];

  int get _pointsCount => widget.sessions.fold(0, (sum, s) => sum + s.points.length);

  Future<void> _openInGoogleMaps(TrackingPointModel p) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${p.latitude},${p.longitude}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final title = isAr ? widget.title : (widget.titleEn ?? widget.title);
    final screen = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.xl),
      backgroundColor: Color(AppColors.background),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 560,
        height: (screen.height * 0.82).clamp(420, 720),
        child: Column(
          children: [
            // Header: same white bar and navy title as the app's pages.
            Container(
              color: Colors.white,
              padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.page, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.heading(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSizes.s2),
                        Text(
                          'legs_points_recorded'.tr(namedArgs: {
                            'length': '${widget.sessions.length}',
                            'length2': '$_pointsCount',
                          }),
                          style: AppStyles.greyContent(context).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppField.iconColor,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (widget.sessions.length > 1)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: TrackingChipsRow(chips: [
                  TrackingChoiceChip(
                    label: 'all_legs_merged'.tr(),
                    selected: _selectedSessionId == null,
                    onTap: () => setState(() {
                      _selectedSessionId = null;
                      _selectedPoint = null;
                    }),
                  ),
                  for (var i = 0; i < widget.sessions.length; i++)
                    TrackingChoiceChip(
                      label: 'tracking_leg_n'.tr(namedArgs: {'n': '${i + 1}'}),
                      dotColor: TrackingPalette.colorAt(i),
                      selected: _selectedSessionId == widget.sessions[i].id,
                      onTap: () => setState(() {
                        _selectedSessionId = widget.sessions[i].id;
                        _selectedPoint = null;
                      }),
                    ),
                ]),
              ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TrackingRouteMap(
                      lines: _lines,
                      selectedPoint: _selectedPoint,
                      onPointTap: (p) => setState(() => _selectedPoint = p),
                    ),
                  ),
                  if (_selectedPoint != null)
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: _SelectedPointCard(
                        point: _selectedPoint!,
                        onOpen: () => _openInGoogleMaps(_selectedPoint!),
                        onClose: () => setState(() => _selectedPoint = null),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Legend(color: Color(AppColors.successGreen), label: 'start_point'.tr()),
                  _Legend(color: Color(AppColors.buttons), label: 'tracking_manual_point'.tr()),
                  _Legend(color: Color(AppColors.failureRed), label: 'end_point'.tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPointCard extends StatelessWidget {
  final TrackingPointModel point;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  const _SelectedPointCard({required this.point, required this.onOpen, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isAr = context.locale.languageCode == 'ar';
    final time = DateFormat('hh:mm a', context.locale.languageCode).format(point.recordedAt);
    final title = point.isStartPoint
        ? 'tracking_leg_started'.tr()
        : point.isEndPoint
            ? 'tracking_leg_ended'.tr()
            : point.getDisplayLabel(isArabic: isAr);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.overlay,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context).copyWith(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSizes.s2),
                Text(
                  '$time · ${'tracking_accuracy_m'.tr(namedArgs: {'m': point.accuracy.toStringAsFixed(0)})}',
                  style: AppStyles.greyContent(context).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text('open_in_google_maps'.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: Color(AppColors.buttons)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppField.iconColor,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        ),
        const SizedBox(width: AppSizes.s6),
        Text(label, style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
      ],
    );
  }
}
