import 'package:app_test/core/widgets/webview_wrapper.dart';
import 'package:app_test/features/reports/data/models/report_webview_model.dart';
import 'package:flutter/material.dart';

class WebviewReportView extends StatelessWidget {
  final ReportWebviewModel webviewData;

  const WebviewReportView({Key? key, required this.webviewData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWebView(
      url: webviewData.webviewUrl,
    );
  }
}
