# reports

The reports catalog. Each report renders natively in Flutter or as a backend WebView, as the server decides.

- `data/repos/reports_repo.dart`, all under `emp_reports/v1/mobile/reports/`:
  - `catalog`: list of reports with `key`, `viewType` and the filters config
  - `filter-options`: departments, employees, request types, time frames
  - `data`: report data for `report_key` and the chosen filters
  - `webview-url`: a signed URL for WebView reports
- `controllers/reports_view_model.dart`: `fetchCatalog`, `fetchFilterOptions`, `fetchReportData`, `fetchWebviewUrl`.
- `views/reports_catalog_screen.dart`: catalog.
- `views/report_details_screen.dart`: turns time-frame keys (`today`, `this_week`, `last_30_days`, `this_quarter`, ...) into date ranges and picks the renderer:
  - `viewType == 'flutter'`: switch on `report.key`. `requests-summary` → `RequestsSummaryReportView`, `leave-requests` → `LeaveRequestsReportView`, `employee-leave-schedule` → `EmployeeLeaveScheduleReportView`, `annual-leave-entitlement` → `AnnualLeaveEntitlementReportView`, `attendance-report` and others → `FlutterReportView`
  - otherwise: `WebviewReportView` with the URL from `webview-url`
- `views/widgets/filters_bottom_sheet.dart`: filters driven by `FiltersConfigModel`. `report_compare_tabs.dart` compares periods.
- `data/models/`: one model per native report, plus the catalog, filter options and WebView models.

To add a native report, add a model, a view and a `case` for its key in `report_details_screen.dart`, and parse its data in `ReportsViewModel`.
