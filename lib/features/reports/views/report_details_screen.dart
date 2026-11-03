import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/reports/controllers/reports_view_model.dart';
import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/views/widgets/annual_leave_entitlement_report_view.dart';
import 'package:app_test/features/reports/views/widgets/employee_leave_schedule_report_view.dart';
import 'package:app_test/features/reports/views/widgets/filters_bottom_sheet.dart';
import 'package:app_test/features/reports/views/widgets/flutter_report_view.dart';
import 'package:app_test/features/reports/views/widgets/leave_requests_report_view.dart';
import 'package:app_test/features/reports/views/widgets/report_details_shimmer.dart';
import 'package:app_test/features/reports/views/widgets/requests_summary_report_view.dart';
import 'package:app_test/features/reports/views/widgets/webview_report_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';

class ReportDetailsScreen extends StatefulWidget {
  final ReportCatalogModel report;

  const ReportDetailsScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late ReportsViewModel _viewModel;
  Map<String, dynamic> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsViewModel();

    _currentFilters['department_ids'] = <int>[];
    _currentFilters['employee_ids'] = <int>[];
    _currentFilters['request_type_ids'] = null;
    
    final defaultPeriodType = widget.report.filtersConfig.defaultPeriodType;
    _currentFilters['use_time_period'] = true;
    _currentFilters['period_type'] = defaultPeriodType.isNotEmpty ? defaultPeriodType : 'time_frame';

    if (_currentFilters['period_type'] == 'time_frame' &&
        widget.report.filtersConfig.defaultTimeFrame.isNotEmpty) {
      _currentFilters['time_frame'] = widget.report.filtersConfig.defaultTimeFrame;
    }
    
    _currentFilters['compare'] = false;
    _currentFilters['compare_period_type'] = 'time_frame';

    _viewModel.fetchFilterOptions(context, widget.report.key).then((_) {
      _loadReportData();
    });
  }

  Future<void> _loadReportData() async {
    final Map<String, dynamic> requestFilters = Map<String, dynamic>.from(_currentFilters);
    
    if (requestFilters['use_time_period'] == false) {
      requestFilters.remove('period_type');
      requestFilters.remove('time_frame');
      requestFilters.remove('date_from');
      requestFilters.remove('date_to');
    }
    requestFilters.remove('use_time_period');
    
    if (widget.report.viewType == 'flutter') {
      requestFilters['report_key'] = widget.report.key;
      await _viewModel.fetchReportData(context, requestFilters);
    } else {
      await _viewModel.fetchWebviewUrl(
          context, widget.report.key, requestFilters);
    }
  }

  void _showFilters() {
    if (_viewModel.currentFilterOptions == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Material(
          color: Color(AppColors.background),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          clipBehavior: Clip.antiAlias,
          child: FiltersBottomSheet(
            filtersConfig: widget.report.filtersConfig,
            filterOptions: _viewModel.currentFilterOptions!,
            initialFilters: _currentFilters,
            onApplyFilters: (filters) {
              setState(() {
                _currentFilters = filters;
              });
              _loadReportData();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWebview = widget.report.viewType != 'flutter';

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: TemplatePage(
        pageContext: context,
        title: widget.report.name,
        // WebView: no bookmark, no filter, no pull-to-refresh (ListView would break WebView height)
        showBookmark: !isWebview,
        onRefresh: isWebview ? null : () async => _loadReportData(),
        actions: isWebview
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.filter_alt_outlined,
                      color: Color(AppColors.buttons)),
                  onPressed: _showFilters,
                ),
              ],
        body: Consumer<ReportsViewModel>(
          builder: (context, viewModel, child) {
            if (isWebview) {
              // WebView fills the entire scaffold body
              return _buildBody(context, viewModel);
            }
            // Flutter report view — constrained width + padding
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBody(context, viewModel),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _calculateDateRangeForTimeFrame(String key) {
    final now = DateTime.now();
    DateTime? from;
    DateTime? to;
    String fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

    switch (key.toLowerCase()) {
      case 'today':
        from = DateTime(now.year, now.month, now.day);
        to = from;
        break;
      case 'yesterday':
        from = DateTime(now.year, now.month, now.day - 1);
        to = from;
        break;
      case 'this_week':
        from = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        to = from.add(const Duration(days: 6));
        break;
      case 'last_week':
        final thisWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        from = thisWeekStart.subtract(const Duration(days: 7));
        to = from.add(const Duration(days: 6));
        break;
      case 'this_month':
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0);
        break;
      case 'last_month':
        from = DateTime(now.year, now.month - 1, 1);
        to = DateTime(now.year, now.month, 0);
        break;
      case 'this_year':
        from = DateTime(now.year, 1, 1);
        to = DateTime(now.year, 12, 31);
        break;
      case 'last_year':
        from = DateTime(now.year - 1, 1, 1);
        to = DateTime(now.year - 1, 12, 31);
        break;
      case 'this_quarter':
        final currentQuarter = ((now.month - 1) / 3).floor();
        from = DateTime(now.year, currentQuarter * 3 + 1, 1);
        to = DateTime(now.year, (currentQuarter + 1) * 3 + 1, 0);
        break;
      case 'last_quarter':
        final prevQuarter = ((now.month - 1) / 3).floor() - 1;
        if (prevQuarter < 0) {
          from = DateTime(now.year - 1, 10, 1);
          to = DateTime(now.year - 1, 12, 31);
        } else {
          from = DateTime(now.year, prevQuarter * 3 + 1, 1);
          to = DateTime(now.year, (prevQuarter + 1) * 3 + 1, 0);
        }
        break;
      case 'last_7_days':
        from = DateTime(now.year, now.month, now.day - 6);
        to = DateTime(now.year, now.month, now.day);
        break;
      case 'last_30_days':
        from = DateTime(now.year, now.month, now.day - 29);
        to = DateTime(now.year, now.month, now.day);
        break;
      case 'last_90_days':
        from = DateTime(now.year, now.month, now.day - 89);
        to = DateTime(now.year, now.month, now.day);
        break;
      default:
        return null;
    }
    return '${fmt(from)} → ${fmt(to)}';
  }

  String? _getDateDescription({required bool isCompare}) {
    final rawData = _viewModel.rawReportData;
    if (rawData != null) {
      final periodSource = isCompare
          ? (rawData['compare'] is Map<String, dynamic> ? rawData['compare']['period'] : null)
          : rawData['period'];
      if (periodSource is Map<String, dynamic>) {
        final from = periodSource['from']?.toString() ?? '';
        final to = periodSource['to']?.toString() ?? '';
        if (from.isNotEmpty && to.isNotEmpty) {
          return '$from → $to';
        }
      }
    }

    final periodType = isCompare
        ? (_currentFilters['compare_period_type'] as String? ?? 'time_frame')
        : (_currentFilters['period_type'] as String? ?? 'time_frame');

    if (periodType == 'from_to') {
      final fromKey = isCompare ? 'compare_date_from' : 'date_from';
      final toKey = isCompare ? 'compare_date_to' : 'date_to';
      final from = _currentFilters[fromKey] as String?;
      final to = _currentFilters[toKey] as String?;
      if (from != null && to != null && from.isNotEmpty && to.isNotEmpty) {
        return '$from → $to';
      }
    } else {
      final tfKey = isCompare ? 'compare_time_frame' : 'time_frame';
      final selectedTf = _currentFilters[tfKey] as String? ??
          (isCompare ? null : widget.report.filtersConfig.defaultTimeFrame);
      if (selectedTf != null && selectedTf.isNotEmpty) {
        final computed = _calculateDateRangeForTimeFrame(selectedTf);
        if (computed != null) return computed;

        final options = _viewModel.currentFilterOptions?.timeFrames;
        final match = options?.where((e) => e.key == selectedTf).firstOrNull;
        if (match != null && match.label.isNotEmpty) return match.label;

        return selectedTf;
      }
    }
    return null;
  }

  Widget _buildBody(BuildContext context, ReportsViewModel viewModel) {
    if (viewModel.isLoadingFilters) {
      return const ReportDetailsShimmer();
    }

    if (viewModel.filtersError != null &&
        viewModel.currentFilterOptions == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Color(AppColors.failureRed), size: 48),
            const SizedBox(height: 12),
            Text('فشل تحميل الفلاتر: ${viewModel.filtersError}',
                style: AppStyles.redContent(context), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppColors.buttons)),
              onPressed: () =>
                  viewModel.fetchFilterOptions(context, widget.report.key),
              child: Text('try_again'.tr(),
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (widget.report.viewType == 'flutter') {
      if (viewModel.isLoadingData) {
        return const ReportDetailsShimmer();
      }
      if (viewModel.dataError != null) {
        return Center(
            child: Text(viewModel.dataError!,
                style: AppStyles.redContent(context)));
      }

      final currentSubtitle = _getDateDescription(isCompare: false);
      final compareSubtitle = _getDateDescription(isCompare: true);

      switch (widget.report.key) {
        case 'requests-summary':
          if (viewModel.requestsSummaryData != null) {
            return RequestsSummaryReportView(
              data: viewModel.requestsSummaryData!,
              currentSubtitle: currentSubtitle,
              compareSubtitle: compareSubtitle,
            );
          }
          break;
        case 'leave-requests':
          if (viewModel.leaveRequestsData != null) {
            return LeaveRequestsReportView(
              data: viewModel.leaveRequestsData!,
              currentSubtitle: currentSubtitle,
              compareSubtitle: compareSubtitle,
            );
          }
          break;
        case 'employee-leave-schedule':
          if (viewModel.leaveScheduleData != null) {
            return EmployeeLeaveScheduleReportView(
              data: viewModel.leaveScheduleData!,
              currentSubtitle: currentSubtitle,
              compareSubtitle: compareSubtitle,
            );
          }
          break;
        case 'annual-leave-entitlement':
          if (viewModel.annualLeaveEntitlementData != null) {
            return AnnualLeaveEntitlementReportView(
              data: viewModel.annualLeaveEntitlementData!,
              currentSubtitle: currentSubtitle,
              compareSubtitle: compareSubtitle,
            );
          }
          break;
        case 'attendance-report':
        default:
          if (viewModel.currentReportData != null) {
            return FlutterReportView(
              reportData: viewModel.currentReportData!,
              currentSubtitle: currentSubtitle,
              compareSubtitle: compareSubtitle,
            );
          }
          break;
      }

      return const ReportDetailsShimmer();
    } else {
      if (viewModel.isLoadingWebview) {
        return const ReportDetailsShimmer();
      }
      if (viewModel.webviewError != null) {
        return Center(
            child: Text(viewModel.webviewError!,
                style: AppStyles.redContent(context)));
      }
      if (viewModel.currentWebviewData != null) {
        return WebviewReportView(webviewData: viewModel.currentWebviewData!);
      }
      return const ReportDetailsShimmer();
    }
  }
}
