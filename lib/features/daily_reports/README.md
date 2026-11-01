# daily_reports

Employees write a daily work report. Managers read their department's reports.

- `services/daily_reports_service.dart`: CRUD on `emp_reports/v1/daily_reports`.
- `controllers/daily_reports_controller.dart`: `DailyReportsProvider` (app-wide provider). `fetchReports` (mine, or the department view via `toggleDepartmentView`), filters (date, department, employee), `addReport`, `updateReport`, `deleteReport`.
- `models/daily_report_model.dart`: report, attachments, employee profile.
- `views/`: list, details, and the add/edit screen (text plus attachments).

The employee profile screen (`employee_profiles`) embeds a daily-reports section for that employee.
