class ReportWebviewModel {
  final String reportKey;
  final String reportName;
  final String webviewUrl;
  final String token;
  final String expiresAt;

  ReportWebviewModel({
    required this.reportKey,
    required this.reportName,
    required this.webviewUrl,
    required this.token,
    required this.expiresAt,
  });

  factory ReportWebviewModel.fromJson(Map<String, dynamic> json) {
    return ReportWebviewModel(
      reportKey: json['report_key'] ?? '',
      reportName: json['report_name'] ?? '',
      webviewUrl: json['webview_url'] ?? '',
      token: json['token'] ?? '',
      expiresAt: json['expires_at'] ?? '',
    );
  }
}
