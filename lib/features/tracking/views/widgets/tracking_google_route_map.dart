import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import '../../data/models/tracking_point.model.dart';
import 'tracking_route_map.dart';

/// [TrackingRouteMap] on Google Maps: a polyline per line (faded when [TrackingRouteLine.dimmed]),
/// markers for start (green), end (red), manual points (route colour, title in the info window)
/// and the live position. The camera fits every point whenever the lines change.
class TrackingGoogleRouteMap extends StatefulWidget {
  final List<TrackingRouteLine> lines;
  final TrackingPointModel? selectedPoint;
  final ValueChanged<TrackingPointModel>? onPointTap;

  const TrackingGoogleRouteMap({super.key, required this.lines, this.selectedPoint, this.onPointTap});

  @override
  State<TrackingGoogleRouteMap> createState() => _TrackingGoogleRouteMapState();
}

class _TrackingGoogleRouteMapState extends State<TrackingGoogleRouteMap> {
  GoogleMapController? _controller;
  String _fittedFor = '';

  List<TrackingPointModel> get _allPoints => [for (final l in widget.lines) ...l.points];

  /// Changes when the set of points changes, so the camera refits only then (not on a tap).
  String get _signature {
    final pts = _allPoints;
    if (pts.isEmpty) return '';
    return '${pts.length}|${pts.first.latitude},${pts.first.longitude}|${pts.last.latitude},${pts.last.longitude}';
  }

  @override
  void didUpdateWidget(covariant TrackingGoogleRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature != _fittedFor) _fit();
  }

  Future<void> _fit() async {
    final controller = _controller;
    final pts = _allPoints;
    if (controller == null || pts.isEmpty) return;
    _fittedFor = _signature;
    CameraUpdate update;
    if (pts.length == 1) {
      update = CameraUpdate.newLatLngZoom(LatLng(pts.first.latitude, pts.first.longitude), 15);
    } else {
      var minLat = pts.first.latitude, maxLat = minLat, minLng = pts.first.longitude, maxLng = minLng;
      for (final p in pts) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }
      if (maxLat - minLat < 0.002) {
        minLat -= 0.001;
        maxLat += 0.001;
      }
      if (maxLng - minLng < 0.002) {
        minLng -= 0.001;
        maxLng += 0.001;
      }
      update = CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 48);
    }
    try {
      await controller.animateCamera(update);
    } catch (_) {
      // The map may not be laid out yet; the next update fits it.
      _fittedFor = '';
    }
  }

  static double _hue(Color c) => HSVColor.fromColor(c).hue;

  Set<Polyline> get _polylines => {
        for (var i = 0; i < widget.lines.length; i++)
          if (widget.lines[i].points.length > 1)
            Polyline(
              polylineId: PolylineId('line_$i'),
              color: widget.lines[i].color.withValues(alpha: widget.lines[i].dimmed ? 0.25 : 0.9),
              width: widget.lines[i].dimmed ? 3 : 5,
              points: [
                for (final p in widget.lines[i].points.where((p) => !p.isStartPoint && !p.isEndPoint))
                  LatLng(p.latitude, p.longitude),
              ],
              jointType: JointType.round,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              zIndex: widget.lines[i].dimmed ? 0 : 1,
            ),
      };

  Set<Marker> _markers(bool isArabic) {
    final markers = <Marker>{};
    for (var i = 0; i < widget.lines.length; i++) {
      final line = widget.lines[i];
      final alpha = line.dimmed ? 0.45 : 1.0;
      for (var j = 0; j < line.points.length; j++) {
        final p = line.points[j];
        if (!p.isKeyPoint) continue;
        final hue = p.isStartPoint
            ? BitmapDescriptor.hueGreen
            : p.isEndPoint
                ? BitmapDescriptor.hueRed
                : _hue(line.color);
        final title = p.isStartPoint
            ? 'tracking_leg_started'.tr()
            : p.isEndPoint
                ? 'tracking_leg_ended'.tr()
                : p.getDisplayLabel(isArabic: isArabic);
        markers.add(Marker(
          markerId: MarkerId('p_${i}_$j'),
          position: LatLng(p.latitude, p.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          alpha: alpha,
          infoWindow: InfoWindow(
            title: title,
            snippet: DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(p.recordedAt),
          ),
          zIndexInt: widget.selectedPoint == p ? 3 : 2,
          onTap: widget.onPointTap == null ? null : () => widget.onPointTap!(p),
        ));
      }
      if (line.showLivePosition && line.points.isNotEmpty) {
        final p = line.points.lastWhere((p) => !p.isEndPoint, orElse: () => line.points.last);
        markers.add(Marker(
          markerId: MarkerId('live_$i'),
          position: LatLng(p.latitude, p.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hue(line.color)),
          alpha: alpha,
          infoWindow: InfoWindow(
            title: line.liveLabel,
            snippet: DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(p.recordedAt),
          ),
          zIndexInt: 4,
        ));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final pts = _allPoints;
    final isArabic = context.locale.languageCode == 'ar';
    final first = pts.isEmpty ? const LatLng(30.0444, 31.2357) : LatLng(pts.first.latitude, pts.first.longitude);
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: first, zoom: pts.isEmpty ? 10 : 14),
            polylines: _polylines,
            markers: _markers(isArabic),
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: kIsWeb,
            compassEnabled: false,
            // The map sits inside scrolling pages and dialogs: let it take pan / zoom gestures.
            gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
            onMapCreated: (c) {
              _controller = c;
              WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
            },
          ),
        ),
        if (pts.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.card, boxShadow: AppShadows.card),
              child: Text('no_coordinates_recorded_to_display'.tr(),
                  style: AppStyles.greyContent(context).copyWith(fontSize: 12, color: Color(AppColors.secondaryButton))),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
