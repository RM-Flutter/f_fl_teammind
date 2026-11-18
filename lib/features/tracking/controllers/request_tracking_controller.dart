import 'package:flutter/material.dart';

import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/location_tracking/location_tracking_service.dart';
import '../data/models/request_tracking.model.dart';
import '../data/models/tracking_session.model.dart';
import '../data/repos/tracking_repo.dart';

/// The "Tracking" tab of one request (API doc screens 2 and 3).
///
/// Loads `GET /requests/{id}` and reloads it after every Start / Stop / key point / sync.
/// The phone's recording and queue live in [LocationTrackingService].
class RequestTrackingController extends ChangeNotifier {
  final int requestId;

  /// The signed-in employee owns the request: only then Start / Stop / key point / Sync show.
  final bool isOwner;

  RequestTrackingController({required this.requestId, required this.isOwner});

  RequestTrackingDetailsModel? details;
  bool isLoading = false;
  String? errorMessage;

  /// Start / Stop / key point / sync / map running: buttons wait.
  bool isBusy = false;

  LocationTrackingService get _recorder => LocationTrackingService.instance;

  RequestTrackingInfoModel get tracking => details?.tracking ?? const RequestTrackingInfoModel();
  List<TrackingSessionModel> get sessions => details?.sessions ?? const [];

  TrackingSessionModel? get activeSession {
    final id = tracking.activeSessionId;
    if (id == null) return null;
    for (final s in sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> load(BuildContext context, {bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    final result = await TrackingRepo.getRequestTracking(context: context, requestId: requestId);
    if (result.success && result.data != null) {
      details = result.data;
      errorMessage = null;
      await _syncRecorder();
    } else if (details == null) {
      errorMessage = result.message;
    }
    isLoading = false;
    notifyListeners();
  }

  /// Keeps the phone in step with the server: stop recording a session the server closed, and
  /// resume one that is still open (e.g. after the app was reinstalled) when the permission is
  /// already there.
  Future<void> _syncRecorder() async {
    if (!isOwner || !LocationTrackingService.isSupported) return;
    final serverActive = tracking.activeSessionId;
    final local = _recorder.activeSessionId;
    if (local != null && _recorder.activeRequestId == requestId && local != serverActive) {
      await _recorder.stopRecording();
    }
    if (serverActive != null && _recorder.activeSessionId == null) {
      await _recorder.startRecording(sessionId: serverActive, requestId: requestId);
    }
  }

  Future<void> _busy(Future<void> Function() action) async {
    if (isBusy) return;
    isBusy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> start(BuildContext context) => _busy(() async {
        final permission = await _recorder.requestPermission();
        if (!context.mounted) return;
        if (permission == 'denied') {
          AlertsService.warning(
            context: context,
            title: 'tracking_permission_required',
            message: 'tracking_permission_required_hint',
          );
          return;
        }
        final result = await TrackingRepo.startSession(context: context, requestId: requestId);
        if (!context.mounted) return;
        if (result.success && result.data != null) {
          await _recorder.startRecording(sessionId: result.data!.id, requestId: requestId);
          if (!context.mounted) return;
          AlertsService.success(context: context, title: 'tracking_started', message: 'tracking_started_hint');
        } else {
          AlertsService.error(context: context, title: 'tracking', message: result.message ?? 'something_went_wrong');
        }
        if (context.mounted) await load(context, silent: true);
      });

  Future<void> stop(BuildContext context) => _busy(() async {
        final sessionId = tracking.activeSessionId;
        if (sessionId == null) return;
        // Send what is queued before closing the session (if there is a network).
        await _recorder.flush(force: true, requestId: requestId);
        if (!context.mounted) return;
        final result = await TrackingRepo.stopSession(context: context, sessionId: sessionId);
        if (!context.mounted) return;
        if (result.success) {
          if (_recorder.activeSessionId == sessionId) await _recorder.stopRecording();
          // Points taken between the first upload and the stop are still accepted.
          await _recorder.flush(force: true, requestId: requestId);
          if (!context.mounted) return;
          AlertsService.success(
              context: context, title: 'tracking_stopped', message: 'tracking_session_ended_route_saved');
        } else {
          AlertsService.error(context: context, title: 'tracking', message: result.message ?? 'something_went_wrong');
        }
        if (context.mounted) await load(context, silent: true);
      });

  Future<void> addKeyPoint(BuildContext context, String? label) => _busy(() async {
        final saved = await _recorder.addManualPoint(label: label);
        if (!context.mounted) return;
        if (!saved) {
          AlertsService.warning(
            context: context,
            title: 'tracking_waiting_for_location',
            message: 'tracking_key_point_no_location',
          );
          return;
        }
        AlertsService.success(
          context: context,
          title: 'tracking_point_saved',
          message: (label == null || label.isEmpty) ? 'tracking_point_saved_hint' : label,
        );
        await load(context, silent: true);
      });

  /// "Sync now": late points of closed sessions are still accepted while their time is inside
  /// the session.
  Future<void> syncNow(BuildContext context) => _busy(() async {
        final allSent = await _recorder.flush(force: true, requestId: requestId);
        if (!context.mounted) return;
        if (allSent) {
          AlertsService.success(
              context: context, title: 'sync_now', message: 'all_points_synced_uploaded_successfully');
        } else {
          AlertsService.warning(context: context, title: 'sync_now', message: 'tracking_sync_failed_hint');
        }
        await load(context, silent: true);
      });

  /// The full route for the map pop-up (`GET /requests/{id}/path`).
  Future<List<TrackingSessionModel>?> loadPath(BuildContext context) async {
    List<TrackingSessionModel>? path;
    await _busy(() async {
      final mainPoints = [for (final s in sessions) ...s.points];
      final result = await TrackingRepo.getPath(context: context, requestId: requestId, mainPoints: mainPoints);
      if (!context.mounted) return;
      if (result.success) {
        path = result.data;
      } else {
        AlertsService.error(context: context, title: 'tracking', message: result.message ?? 'something_went_wrong');
      }
    });
    return path;
  }
}
