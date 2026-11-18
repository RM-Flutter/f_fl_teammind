import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:app_test/core/models/tracking_queue_point.model.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';

/// What the phone can do with the location right now. The server only learns
/// `permission_state` from it; the rest is shown to the employee.
enum TrackingLocationStatus { ok, waitingForLocation, permissionRequired, permissionLimited, offline }

/// Records the employee's location while a request-linked tracking session is open, keeps the
/// points in a local queue and uploads them (API doc "التتبع في الخلفية").
///
/// - One point a minute while a session is active. Android keeps recording through a foreground
///   service (ongoing notification); iOS through the `location` background mode.
/// - Upload rules (the app's decision, the server does not check them): no new batch within 2 min
///   of the last successful upload; then upload when the employee moved 300 m or more, otherwise
///   at most every 10 min. A manual point is sent at once with the whole queue. At most 100 points
///   per request. "Too many requests" → wait one minute.
/// - Response: drop `accepted_ids` and `rejected` only. If the session is no longer `active`, the
///   server closed it: stop recording.
/// - The app never makes up coordinates: no fix means a gap.
///
/// Mobile only. The active session and the queue survive app restarts (SharedPreferences).
class LocationTrackingService extends ChangeNotifier with WidgetsBindingObserver {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  static const String _kActive = 'trackingActiveSession';
  static const String _kQueue = 'trackingQueue';
  static const String _kLastUpload = 'trackingLastUploadAt';
  static const String _base = '/emp_requests/v1/tracking';

  static const Duration sampleEvery = Duration(minutes: 1);
  static const Duration _minGapAfterUpload = Duration(minutes: 2);
  static const Duration _maxGapBetweenUploads = Duration(minutes: 10);
  static const double _uploadAfterMeters = 300;
  static const int _maxPointsPerRequest = 100;

  final Uuid _uuid = const Uuid();

  int? _activeSessionId;
  int? _activeRequestId;
  List<TrackingQueuePoint> _queue = [];

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _sampleTimer;
  Timer? _flushTimer;

  Position? _latest;
  DateTime? _lastEnqueuedAt;
  DateTime? _lastSuccessAt;
  double? _lastUploadedLat;
  double? _lastUploadedLng;
  DateTime? _rateLimitedUntil;

  bool _initialized = false;
  bool _uploading = false;
  bool _online = true;
  bool _locationBlocked = false;
  String _permissionState = 'granted';

  /// Recording works on Android and iOS only (a browser cannot track with the page closed).
  static bool get isSupported => !PlatformIs.web && PlatformIs.mobile;

  int? get activeSessionId => _activeSessionId;
  int? get activeRequestId => _activeRequestId;
  bool get isRecording => _positionSub != null;
  String get permissionState => _permissionState;

  TrackingLocationStatus get status {
    if (_locationBlocked) return TrackingLocationStatus.permissionRequired;
    if (!_online) return TrackingLocationStatus.offline;
    if (isRecording && _latest == null) return TrackingLocationStatus.waitingForLocation;
    if (PlatformIs.iOS && _permissionState == 'limited') return TrackingLocationStatus.permissionLimited;
    return TrackingLocationStatus.ok;
  }

  /// Points of [requestId] still waiting to be uploaded.
  int pendingCount(int requestId) => _queue.where((p) => p.requestId == requestId).length;

  // ───────────────────────── start-up ─────────────────────────

  /// Loads the queue and resumes recording if a session was active when the app closed.
  /// Never asks for a permission.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _load();
    if (!isSupported) return;
    WidgetsBinding.instance.addObserver(this);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.every((r) => r == ConnectivityResult.none);
      if (online != _online) {
        _online = online;
        notifyListeners();
      }
      if (online) unawaited(flush());
    });
    try {
      final results = await Connectivity().checkConnectivity();
      _online = !results.every((r) => r == ConnectivityResult.none);
    } catch (_) {}
    if (_activeSessionId != null) {
      final permission = await Geolocator.checkPermission();
      _permissionState = _stateFor(permission);
      if (_permissionState == 'denied') {
        _locationBlocked = true;
      } else {
        _beginRecording();
      }
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // The employee may have changed the permission in the phone settings.
    unawaited(_refreshPermission());
    unawaited(flush());
  }

  Future<void> _refreshPermission() async {
    if (_activeSessionId == null) return;
    final enabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    _permissionState = _stateFor(permission);
    final blocked = !enabled || _permissionState == 'denied';
    if (blocked != _locationBlocked) {
      _locationBlocked = blocked;
      if (!blocked && !isRecording) _beginRecording();
    }
    notifyListeners();
  }

  // ───────────────────────── permission ─────────────────────────

  static String _stateFor(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
        return 'granted';
      case LocationPermission.whileInUse:
        return 'limited';
      default:
        return 'denied';
    }
  }

  /// Asks for the location (and, on iOS, "Always") when needed. Returns the `permission_state`:
  /// `granted`, `limited` or `denied`. Location turned off counts as `denied`.
  Future<String> requestPermission() async {
    if (!isSupported) return 'denied';
    if (!await Geolocator.isLocationServiceEnabled()) {
      _locationBlocked = true;
      notifyListeners();
      return 'denied';
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    // iOS stops giving points once the app is closed with "While Using": ask for "Always".
    // Android keeps recording through the foreground service, so it does not need it.
    if (PlatformIs.iOS && permission == LocationPermission.whileInUse) {
      try {
        await ph.Permission.locationAlways.request();
        permission = await Geolocator.checkPermission();
      } catch (_) {}
    }
    _permissionState = _stateFor(permission);
    _locationBlocked = _permissionState == 'denied';
    notifyListeners();
    return _permissionState;
  }

  Future<void> openSettings() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  // ───────────────────────── recording ─────────────────────────

  /// Call after the server answered Start with session [sessionId].
  Future<void> startRecording({required int sessionId, required int requestId}) async {
    if (!isSupported) return;
    if (_activeSessionId == sessionId && isRecording) return;
    _endRecording();
    _activeSessionId = sessionId;
    _activeRequestId = requestId;
    _lastEnqueuedAt = null;
    _latest = null;
    await _saveActive();
    if (!_locationBlocked) _beginRecording();
    notifyListeners();
  }

  /// Stops recording; the points already in the queue stay until they are uploaded.
  Future<void> stopRecording() async {
    _endRecording();
    _activeSessionId = null;
    _activeRequestId = null;
    _locationBlocked = false;
    await _saveActive();
    notifyListeners();
  }

  /// Logout: forget the session and the queue.
  Future<void> clearAll() async {
    await stopRecording();
    _queue = [];
    _lastSuccessAt = null;
    await _saveQueue();
    await CacheHelper.deleteData(key: _kLastUpload);
    notifyListeners();
  }

  LocationSettings get _settings {
    if (PlatformIs.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: sampleEvery,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: 'tracking_notification_title'.tr(),
          notificationText: 'tracking_notification_text'.tr(),
          notificationChannelName: 'tracking_notification_channel'.tr(),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      activityType: ActivityType.otherNavigation,
      pauseLocationUpdatesAutomatically: false,
      allowBackgroundLocationUpdates: true,
      showBackgroundLocationIndicator: true,
    );
  }

  void _beginRecording() {
    if (isRecording || _activeSessionId == null) return;
    _positionSub = Geolocator.getPositionStream(locationSettings: _settings).listen(
      _onPosition,
      onError: (Object e) {
        debugPrint('LocationTrackingService stream error: $e');
        if (e is PermissionDeniedException || e is LocationServiceDisabledException) {
          _locationBlocked = true;
          _permissionState = 'denied';
          _endRecording();
          notifyListeners();
        }
      },
    );
    _sampleTimer = Timer.periodic(sampleEvery, (_) => _sample());
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) => flush());
  }

  void _endRecording() {
    _positionSub?.cancel();
    _positionSub = null;
    _sampleTimer?.cancel();
    _sampleTimer = null;
    _flushTimer?.cancel();
    _flushTimer = null;
  }

  void _onPosition(Position position) {
    final first = _latest == null;
    _latest = position;
    if (_locationBlocked) _locationBlocked = false;
    if (_lastEnqueuedAt == null) _sample(); // the first fix is the start of the route
    if (first) notifyListeners();
  }

  /// Adds the latest fix to the queue, once a minute. A fix older than the last queued one is
  /// not repeated: no new fix means a gap, never a made-up point.
  void _sample() {
    final p = _latest;
    final sessionId = _activeSessionId;
    if (p == null || sessionId == null) return;
    final at = p.timestamp.toLocal();
    if (_lastEnqueuedAt != null && !at.isAfter(_lastEnqueuedAt!)) return;
    _enqueue(_fromPosition(p, sessionId: sessionId, pointType: 'auto'));
    _lastEnqueuedAt = at;
  }

  TrackingQueuePoint _fromPosition(Position p, {required int sessionId, required String pointType, String? label}) =>
      TrackingQueuePoint(
        clientPointId: _uuid.v4(),
        sessionId: sessionId,
        requestId: _activeRequestId ?? 0,
        latitude: p.latitude,
        longitude: p.longitude,
        recordedAt: p.timestamp.toLocal(),
        accuracy: p.accuracy,
        speed: p.speed,
        heading: p.heading,
        altitude: p.altitude,
        pointType: pointType,
        label: label,
      );

  void _enqueue(TrackingQueuePoint point) {
    _queue.add(point);
    unawaited(_saveQueue());
    notifyListeners();
  }

  /// Saves a key point at the current location and sends the whole queue right away.
  /// Returns false when there is no location to save (no point is invented).
  Future<bool> addManualPoint({String? label}) async {
    final sessionId = _activeSessionId;
    if (sessionId == null || !isSupported) return false;
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
      );
    } catch (e) {
      debugPrint('LocationTrackingService manual point: $e');
    }
    final latest = _latest;
    if (position == null && latest != null && DateTime.now().difference(latest.timestamp.toLocal()) < const Duration(minutes: 2)) {
      position = latest;
    }
    if (position == null) return false;
    _enqueue(_fromPosition(position, sessionId: sessionId, pointType: 'manual', label: label));
    await flush(force: true);
    return true;
  }

  // ───────────────────────── upload ─────────────────────────

  /// Uploads the queue when the rules allow it. [force] skips the timing rules (manual point,
  /// Stop, Sync now); [requestId] limits it to one request's sessions.
  /// Returns true when nothing of that scope is left in the queue.
  Future<bool> flush({bool force = false, int? requestId}) async {
    if (_uploading) return false;
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    if (Provider.of<AppConfigService>(context, listen: false).token.isEmpty) return false;

    final now = DateTime.now();
    if (_rateLimitedUntil != null && now.isBefore(_rateLimitedUntil!)) return false;

    List<TrackingQueuePoint> scope() =>
        _queue.where((p) => requestId == null || p.requestId == requestId).toList();
    if (scope().isEmpty) return true;

    if (!force) {
      final last = _lastSuccessAt;
      if (last != null && now.difference(last) < _minGapAfterUpload) return false;
      final newest = scope().last;
      final moved = _lastUploadedLat == null ||
          Geolocator.distanceBetween(_lastUploadedLat!, _lastUploadedLng!, newest.latitude, newest.longitude) >=
              _uploadAfterMeters;
      final due = last == null || now.difference(last) >= _maxGapBetweenUploads;
      if (!moved && !due) return false;
    }

    _uploading = true;
    try {
      final sessionIds = scope().map((p) => p.sessionId).toSet();
      for (final sessionId in sessionIds) {
        final keepGoing = await _uploadSession(context, sessionId);
        if (!keepGoing) break;
      }
    } finally {
      _uploading = false;
      await _saveQueue();
      notifyListeners();
    }
    return scope().isEmpty;
  }

  /// Sends one session's points in batches of 100. Returns false to stop the whole upload
  /// (no network, rate limit, server error).
  Future<bool> _uploadSession(BuildContext context, int sessionId) async {
    while (true) {
      final batch = _queue.where((p) => p.sessionId == sessionId).take(_maxPointsPerRequest).toList();
      if (batch.isEmpty) return true;
      dynamic body;
      try {
        final response = await DioHelper.postData(
          context: context,
          url: '$_base/sessions/$sessionId/points',
          query: null,
          data: {
            'permission_state': _permissionState,
            'points': batch.map((p) => p.toApiJson()).toList(),
          },
        );
        body = response.data;
      } catch (e) {
        debugPrint('LocationTrackingService upload failed: $e');
        return false;
      }
      if (body is! Map) return false;

      if (body['status'] == true) {
        final done = <String>{
          ...(body['accepted_ids'] as List? ?? const []).map((e) => e.toString()),
          ...(body['rejected'] as List? ?? const [])
              .whereType<Map>()
              .map((r) => r['client_point_id']?.toString() ?? ''),
        };
        _queue.removeWhere((p) => p.sessionId == sessionId && done.contains(p.clientPointId));
        _lastSuccessAt = DateTime.now();
        _lastUploadedLat = batch.last.latitude;
        _lastUploadedLng = batch.last.longitude;
        await CacheHelper.setString(key: _kLastUpload, value: _lastSuccessAt!.toIso8601String());

        final data = body['data'] is Map ? body['data'] as Map : const {};
        final serverStatus = data['status']?.toString();
        if (serverStatus != null && serverStatus != 'active' && _activeSessionId == sessionId) {
          // Approved / refused / cancelled request, or 3 hours with no points.
          await stopRecording();
        } else if (serverStatus == 'active' && _activeSessionId == null && isSupported) {
          // The server opened the session again after a break.
          await startRecording(sessionId: sessionId, requestId: batch.first.requestId);
        }
        // Nothing accepted or rejected: stop here instead of sending the same batch again.
        if (done.isEmpty) return true;
        continue;
      }

      final message = body['message']?.toString().toLowerCase() ?? '';
      if (message.contains('cancelled') || message.contains('session not found')) {
        _queue.removeWhere((p) => p.sessionId == sessionId);
        if (_activeSessionId == sessionId) await stopRecording();
        return true;
      }
      if (message.contains('too many')) {
        _rateLimitedUntil = DateTime.now().add(const Duration(minutes: 1));
        return false;
      }
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        // A point the server will never accept (e.g. points.3.latitude): drop it, keep the rest.
        final bad = <int>{};
        for (final key in errors.keys) {
          final m = RegExp(r'^points\.(\d+)\.').firstMatch(key.toString());
          if (m != null) bad.add(int.parse(m.group(1)!));
        }
        if (bad.isEmpty) return false;
        final badIds = {for (final i in bad) if (i < batch.length) batch[i].clientPointId};
        _queue.removeWhere((p) => badIds.contains(p.clientPointId));
        continue;
      }
      // "Something went wrong" or anything else: keep the points and try later.
      return false;
    }
  }

  @override
  void dispose() {
    _endRecording();
    _connectivitySub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ───────────────────────── storage ─────────────────────────

  void _load() {
    try {
      final active = CacheHelper.getString(_kActive) as String;
      if (active.isNotEmpty) {
        final m = json.decode(active) as Map<String, dynamic>;
        _activeSessionId = int.tryParse(m['session_id'].toString());
        _activeRequestId = int.tryParse(m['request_id'].toString());
      }
    } catch (_) {}
    try {
      final raw = CacheHelper.getString(_kQueue) as String;
      if (raw.isNotEmpty) {
        _queue = (json.decode(raw) as List)
            .whereType<Map>()
            .map((e) => TrackingQueuePoint.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      _queue = [];
    }
    _lastSuccessAt = DateTime.tryParse(CacheHelper.getString(_kLastUpload) as String);
  }

  Future<void> _saveActive() async {
    if (_activeSessionId == null) {
      await CacheHelper.deleteData(key: _kActive);
    } else {
      await CacheHelper.setString(
        key: _kActive,
        value: json.encode({'session_id': _activeSessionId, 'request_id': _activeRequestId}),
      );
    }
  }

  Future<void> _saveQueue() async {
    if (_queue.isEmpty) {
      await CacheHelper.deleteData(key: _kQueue);
    } else {
      await CacheHelper.setString(key: _kQueue, value: json.encode(_queue.map((p) => p.toJson()).toList()));
    }
  }
}
