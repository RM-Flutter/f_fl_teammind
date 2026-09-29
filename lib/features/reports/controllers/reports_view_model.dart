import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/data/models/report_filter_options_model.dart';
import 'package:app_test/features/reports/data/models/report_data_model.dart';
import 'package:app_test/features/reports/data/models/report_webview_model.dart';
import 'package:app_test/features/reports/data/repos/reports_repo.dart';
import 'package:flutter/material.dart';

class ReportsViewModel extends ChangeNotifier {
  List<ReportCatalogModel> catalogReports = [];
  bool isLoadingCatalog = false;
  String? catalogError;

  ReportFilterOptionsModel? currentFilterOptions;
  bool isLoadingFilters = false;
  String? filtersError;

  ReportDataModel? currentReportData;
  bool isLoadingData = false;
  String? dataError;

  ReportWebviewModel? currentWebviewData;
  bool isLoadingWebview = false;
  String? webviewError;

  Future<void> fetchCatalog(BuildContext context) async {
    isLoadingCatalog = true;
    catalogError = null;
    notifyListeners();

    try {
      final result = await ReportsRepo.getCatalog(context: context);
      if (result.success && result.data != null) {
        final reportsList = result.data!['reports'];
        if (reportsList is List) {
          catalogReports = reportsList
              .map((e) => ReportCatalogModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else {
        catalogError = result.message;
      }
    } catch (e) {
      catalogError = e.toString();
    }

    isLoadingCatalog = false;
    notifyListeners();
  }

  Future<void> fetchFilterOptions(BuildContext context, String reportKey) async {
    isLoadingFilters = true;
    filtersError = null;
    currentFilterOptions = null;
    notifyListeners();

    try {
      final result = await ReportsRepo.getFilterOptions(
        context: context,
        reportKey: reportKey,
      );
      if (result.success && result.data != null) {
        currentFilterOptions = ReportFilterOptionsModel.fromJson(result.data!);
      } else {
        filtersError = result.message;
      }
    } catch (e) {
      filtersError = e.toString();
    }

    isLoadingFilters = false;
    notifyListeners();
  }

  Future<void> fetchReportData(BuildContext context, Map<String, dynamic> filters) async {
    isLoadingData = true;
    dataError = null;
    currentReportData = null;
    notifyListeners();

    try {
      final result = await ReportsRepo.getReportData(
        context: context,
        filters: filters,
      );
      if (result.success && result.data != null) {
        currentReportData = ReportDataModel.fromJson(result.data!);
      } else {
        dataError = result.message;
      }
    } catch (e) {
      dataError = e.toString();
    }

    isLoadingData = false;
    notifyListeners();
  }

  Future<void> fetchWebviewUrl(BuildContext context, String reportKey, Map<String, dynamic> filters) async {
    isLoadingWebview = true;
    webviewError = null;
    currentWebviewData = null;
    notifyListeners();

    try {
      final result = await ReportsRepo.getWebviewUrl(
        context: context,
        reportKey: reportKey,
        filters: filters,
      );
      if (result.success && result.data != null) {
        currentWebviewData = ReportWebviewModel.fromJson(result.data!);
      } else {
        webviewError = result.message;
      }
    } catch (e) {
      webviewError = e.toString();
    }

    isLoadingWebview = false;
    notifyListeners();
  }
}
