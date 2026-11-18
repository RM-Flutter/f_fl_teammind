import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/employee_tracking_summary.model.dart';
import '../data/repos/tracking_repo.dart';

/// Time range of the group map (API doc screen 4).
enum GroupMapMode { live, today, date }

/// The group map (API doc screen 4). The server limits the result to what the user may see:
/// a manager sees the team, HR and top management everyone, an employee only themself.
///
/// - Live: `GET /live`, refreshed every 60 seconds while the screen is open.
/// - Today: `GET /live` and `GET /history?mode=today` with the same page and filters, merged
///   (same employees, same order, same `color_index`), so the card has the state and the route.
/// - A picked day: `GET /history?mode=date&date=...`; the state comes from the sessions.
class GroupTrackingMapController extends ChangeNotifier {
  static const Duration liveRefresh = Duration(seconds: 60);

  GroupMapMode mode = GroupMapMode.live;
  DateTime? pickedDate;
  int page = 1;
  int? selectedEmployeeId;

  /// Filters shared by the three modes.
  String? employeeId;
  String? employeeName;
  String? departmentId;
  String? departmentName;

  /// Live only: hide employees with no active tracking.
  bool onlyTracking = false;

  TrackingEmployeesPage result = const TrackingEmployeesPage();
  bool isLoading = false;
  String? errorMessage;

  Timer? _timer;
  int _loadToken = 0;
  bool _disposed = false;

  List<EmployeeTrackingSummaryModel> get employees => result.employees;
  int get pages => result.pages;
  bool get hasFilters => employeeId != null || departmentId != null;

  EmployeeTrackingSummaryModel? get selected {
    for (final e in employees) {
      if (e.employeeId == selectedEmployeeId) return e;
    }
    return null;
  }

  Future<void> load(BuildContext context, {bool silent = false}) async {
    final token = ++_loadToken;
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    final employeeIds = employeeId == null ? null : [employeeId!];
    final departmentIds = departmentId == null ? null : [departmentId!];

    TrackingEmployeesPage? page0;
    String? error;
    switch (mode) {
      case GroupMapMode.live:
        final r = await TrackingRepo.getLive(
          context: context,
          page: page,
          employeeIds: employeeIds,
          departmentIds: departmentIds,
          onlyTracking: onlyTracking,
        );
        page0 = r.success ? r.data : null;
        error = r.message;
        break;
      case GroupMapMode.today:
        final results = await Future.wait([
          TrackingRepo.getLive(context: context, page: page, employeeIds: employeeIds, departmentIds: departmentIds),
          TrackingRepo.getHistory(context: context, page: page, employeeIds: employeeIds, departmentIds: departmentIds),
        ]);
        final live = results[0], history = results[1];
        if (live.success && history.success && live.data != null && history.data != null) {
          final byId = {for (final h in history.data!.employees) h.employeeId: h};
          page0 = TrackingEmployeesPage(
            employees: [
              for (final e in live.data!.employees) byId[e.employeeId] == null ? e : e.withHistory(byId[e.employeeId]!),
            ],
            total: live.data!.total,
            page: live.data!.page,
            itemsCount: live.data!.itemsCount,
          );
        }
        error = live.success ? history.message : live.message;
        break;
      case GroupMapMode.date:
        final r = await TrackingRepo.getHistory(
          context: context,
          page: page,
          date: pickedDate ?? DateTime.now(),
          employeeIds: employeeIds,
          departmentIds: departmentIds,
        );
        page0 = r.success ? r.data : null;
        error = r.message;
        break;
    }
    if (_disposed || token != _loadToken) return;
    if (page0 != null) {
      result = page0;
      errorMessage = null;
      if (selected == null) selectedEmployeeId = null;
    } else if (!silent || result.employees.isEmpty) {
      errorMessage = error;
    }
    isLoading = false;
    notifyListeners();
    _scheduleRefresh(context);
  }

  void _scheduleRefresh(BuildContext context) {
    _timer?.cancel();
    if (mode != GroupMapMode.live) return;
    _timer = Timer(liveRefresh, () {
      if (!_disposed && context.mounted) load(context, silent: true);
    });
  }

  void setMode(BuildContext context, GroupMapMode value, {DateTime? date}) {
    mode = value;
    if (date != null) pickedDate = date;
    page = 1;
    selectedEmployeeId = null;
    load(context);
  }

  void goToPage(BuildContext context, int value) {
    page = value;
    selectedEmployeeId = null;
    load(context);
  }

  void toggleOnlyTracking(BuildContext context) {
    onlyTracking = !onlyTracking;
    page = 1;
    load(context);
  }

  void applyFilters(BuildContext context, Map<String, String?> filters) {
    String? v(String? s) => (s == null || s.isEmpty) ? null : s;
    employeeId = v(filters['empId']);
    employeeName = employeeId == null ? null : v(filters['empName']);
    departmentId = v(filters['depId']);
    departmentName = departmentId == null ? null : v(filters['depName']);
    page = 1;
    selectedEmployeeId = null;
    load(context);
  }

  void select(int? employeeId) {
    selectedEmployeeId = employeeId;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
