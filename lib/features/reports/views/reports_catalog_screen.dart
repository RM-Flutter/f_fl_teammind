import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/reports/controllers/reports_view_model.dart';
import 'package:app_test/features/reports/data/models/report_catalog_model.dart';
import 'package:app_test/features/reports/views/report_details_screen.dart';
import 'package:app_test/features/reports/views/widgets/reports_catalog_shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportsCatalogScreen extends StatelessWidget {
  const ReportsCatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsViewModel()..fetchCatalog(context),
      child: Consumer<ReportsViewModel>(
        builder: (context, viewModel, child) {
          return TemplatePage(
            pageContext: context,
            title: 'reports'.tr(),
            onRefresh: () async => viewModel.fetchCatalog(context),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildBody(context, viewModel),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReportsViewModel viewModel) {
    if (viewModel.isLoadingCatalog) {
      return const ReportsCatalogShimmer();
    }

    if (viewModel.catalogError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Color(AppColors.failureRed), size: 48),
            const SizedBox(height: 12),
            Text(viewModel.catalogError!, style: AppStyles.redContent(context), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(AppColors.buttons)),
              onPressed: () => viewModel.fetchCatalog(context),
              child: Text('try_again'.tr(), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (viewModel.catalogReports.isEmpty) {
      return Center(child: Text('no_data_found'.tr(), style: AppStyles.content(context)));
    }

    final flutterReports = viewModel.catalogReports.where((r) => r.viewType == 'flutter').toList();
    final webviewReports = viewModel.catalogReports.where((r) => r.viewType != 'flutter').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (flutterReports.isNotEmpty) ...[
          _buildSectionLabel(context, 'mobile_reports'.tr(), Icons.phone_android_outlined),
          const SizedBox(height: 12),
          ...flutterReports.map((r) => _buildReportItem(context, r)),
          const SizedBox(height: 24),
        ],
        if (webviewReports.isNotEmpty) ...[
          _buildSectionLabel(context, 'browser_reports'.tr(), Icons.open_in_browser_outlined),
          const SizedBox(height: 12),
          ...webviewReports.map((r) => _buildReportItem(context, r)),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(AppColors.buttons)),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppStyles.blackContent(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(BuildContext context, ReportCatalogModel report) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailsScreen(report: report),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.name,
                    style: AppStyles.blackContent(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppColors.buttons),
                  ),
                  child: const Icon(Icons.arrow_forward_outlined, color: Colors.white, size: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
