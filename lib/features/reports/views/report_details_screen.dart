import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/reports/controllers/reports_view_model.dart';
import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/views/widgets/filters_bottom_sheet.dart';
import 'package:app_test/features/reports/views/widgets/flutter_report_view.dart';
import 'package:app_test/features/reports/views/widgets/report_details_shimmer.dart';
import 'package:app_test/features/reports/views/widgets/webview_report_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    if (widget.report.filtersConfig.defaultPeriodType == 'time_frame' &&
        widget.report.filtersConfig.defaultTimeFrame.isNotEmpty) {
      _currentFilters['time_frame'] =
          widget.report.filtersConfig.defaultTimeFrame;
    }

    _viewModel.fetchFilterOptions(context, widget.report.key).then((_) {
      _loadReportData();
    });
  }

  Future<void> _loadReportData() async {
    if (widget.report.viewType == 'flutter') {
      _currentFilters['report_key'] = widget.report.key;
      await _viewModel.fetchReportData(context, _currentFilters);
    } else {
      await _viewModel.fetchWebviewUrl(
          context, widget.report.key, _currentFilters);
    }
  }

  void _showFilters() {
    if (_viewModel.currentFilterOptions == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Color(AppColors.background),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: TemplatePage(
        pageContext: context,
        title: widget.report.name,
        onRefresh: () async => _loadReportData(),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined,
                color: Color(AppColors.buttons)),
            onPressed: _showFilters,
          ),
        ],
        body: Consumer<ReportsViewModel>(
          builder: (context, viewModel, child) {
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
      if (viewModel.currentReportData != null) {
        return FlutterReportView(reportData: viewModel.currentReportData!);
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
