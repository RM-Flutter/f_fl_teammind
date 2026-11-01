import 'package:app_test/core/services/app_error_reporter.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/more/team_today_status/data/models/team_today_status_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TeamTodayStatusController extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────────────────

  TeamTodayStatusModel? data;
  bool isLoading = false;
  String? errorMessage;

  /// The currently selected filter chip key.
  /// Possible values: 'all' | 'present' | 'clocked_out' | 'absent' | 'vacation' | 'weekend'
  String selectedFilter = 'all';

  /// Live search query (filters by member name, client-side).
  String searchQuery = '';

  // ── Derived ───────────────────────────────────────────────────────────────

  /// Members after applying filter + search locally — no extra API call needed.
  List<TeamMemberStatus> get filteredMembers {
    var members = data?.members ?? <TeamMemberStatus>[];

    if (selectedFilter != 'all') {
      members = members.where((m) => m.status == selectedFilter).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      members = members
          .where((m) => (m.name ?? '').toLowerCase().contains(q))
          .toList();
    }

    return members;
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> fetchTeamStatus(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: '/emp_requests/v1/manager/team_today_status',
        context: context,
        query: {'status': 'all', 'search': ''},
      );

      if (response.data['status'] == true) {
        data = TeamTodayStatusModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        errorMessage =
            response.data['message']?.toString() ?? 'Something went wrong';
      }
    } catch (e) {
      if (e is DioException) {
        final resData = e.response?.data;
        errorMessage = (resData is Map && resData['message'] != null)
            ? resData['message'].toString()
            : 'Something went wrong';
      } else {
        errorMessage = AppErrorReporter.safeMessage(e);
      }
      debugPrint('TeamTodayStatusController.fetchTeamStatus error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Filter & Search ───────────────────────────────────────────────────────

  void setFilter(String status) {
    if (selectedFilter == status) return;
    selectedFilter = status;
    notifyListeners();
  }

  void setSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }
}
