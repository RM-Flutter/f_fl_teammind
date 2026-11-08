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
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

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
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
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
    final bool isFlutter = report.viewType == 'flutter';
    final Color accentColor = Color(AppColors.buttons);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailsScreen(report: report),
            ),
          );
        },
        child: Row(
          children: [
            AppCardLeadingAvatar(
              icon: isFlutter
                  ? Icons.analytics_outlined
                  : Icons.open_in_browser_outlined,
              borderColor: accentColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                report.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.heading(context),
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(
              label: isFlutter ? 'mobile_reports'.tr() : 'browser_reports'.tr(),
              color: accentColor,
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
