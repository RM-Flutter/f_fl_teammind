import 'package:app_test/features/commissions/data/models/commission_model.dart';
import 'package:app_test/features/commissions/data/repos/commission_repo.dart';
import 'package:flutter/material.dart';

class CommissionListController extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  List<CommissionModel>? commissions;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  // ── Pagination ─────────────────────────────────────────────────────────────
  int _currentPage = 1;
  static const int _perPage = 15;

  // ── Filters ────────────────────────────────────────────────────────────────
  String? filterStatus;   // null = all, 'pending', 'applied', 'paid_separately'
  String? filterFromDate; // YYYY-MM-DD
  String? filterToDate;   // YYYY-MM-DD

  // ── Public helpers ─────────────────────────────────────────────────────────

  /// Called once from the screen's initState.
  Future<void> initializeScreen(BuildContext context) async {
    _reset();
    isLoading = true;
    notifyListeners();
    await _fetchPage(context, page: 1);
    isLoading = false;
    notifyListeners();
  }

  /// Load the next page (called from scroll listener).
  Future<void> loadMore(BuildContext context) async {
    if (isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    notifyListeners();
    _currentPage++;
    await _fetchPage(context, page: _currentPage);
    isLoadingMore = false;
    notifyListeners();
  }

  /// Apply new filter values and reload from page 1.
  Future<void> applyFilters({
    required BuildContext context,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    filterStatus = status;
    filterFromDate = fromDate;
    filterToDate = toDate;
    await initializeScreen(context);
  }

  /// Clear all filters and reload.
  Future<void> clearFilters(BuildContext context) async {
    filterStatus = null;
    filterFromDate = null;
    filterToDate = null;
    await initializeScreen(context);
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _reset() {
    _currentPage = 1;
    hasMore = true;
    commissions = null;
  }

  Future<void> _fetchPage(BuildContext context, {required int page}) async {
    try {
      final result = await CommissionRepo.getMyCommissions(
        context: context,
        status: filterStatus,
        fromDate: filterFromDate,
        toDate: filterToDate,
        perPage: _perPage,
        page: page,
      );

      if (result.success && result.data != null) {
        final rawList = result.data!['data'] as List<dynamic>? ?? [];
        final newItems = rawList
            .map((e) => CommissionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        if (page == 1) {
          commissions = newItems;
        } else {
          commissions?.addAll(newItems);
        }

        // Check pagination via meta
        final meta = result.data!['meta'] as Map<String, dynamic>?;
        if (meta != null) {
          final lastPage = meta['last_page'] as int? ?? 1;
          hasMore = page < lastPage;
        } else {
          hasMore = newItems.length >= _perPage;
        }
      } else {
        hasMore = false;
      }
    } catch (err, trace) {
      hasMore = false;
      debugPrint('CommissionListController error: $err\n$trace');
    }
  }
}
