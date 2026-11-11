# tracking

Employee location tracking tied to a request (spec: "توصيف نظام تتبع الموظفين المرتبط بالطلبات" in the
"خطط تطوير" Google Doc). **UI and design only. There are no API calls; all data comes from
`data/dummy/tracking_dummy_data.dart`.** Every screen uses the app's design system (`AppCard`,
`AppStatusBadge`, `AppSectionHeader`, `AppSpacing`, `AppColors.statusTones`, `AppFieldShell`,
`AppFilterSheetFrame`) so it looks like the rest of the app.

## Data
- `data/models/`: `TrackingSessionModel` (one leg: every Start / Stop is a new leg),
  `TrackingPointModel` (auto GPS point or manual key point with an optional title),
  `EmployeeTrackingSummaryModel` (one employee on the group map), `TrackingReportRowModel`
  (one row of the reports) and the enums in `tracking_status.enum.dart`:
  `RequestTrackingStatus` (request level), `TrackingSessionStatus` (leg level),
  `TrackingLocationState` (waiting / permission required / permission limited / offline) and
  `EmployeeTrackingPresence` (active / stopped / offline / no active tracking).
  Status colours come from the app palette.
- `data/dummy/tracking_dummy_data.dart`: sample legs, 13 employees (2 pages of the group map),
  `routeFor()` (a route per employee) and `reportRows()`.

## Screens and widgets
| Spec screen | Where |
|---|---|
| 1. Requests list filter (with / without tracking data / any) | `requests/main_request_layout/views/widgets/search_filter_widget.dart` (`trackingFilter`, sent as `tracking` in the filter map) |
| 2. Request detail, employee | `views/widgets/tracking_section_employee.dart`: Start (only on the request date, not for a cancelled request) / Stop, Add key point (only while a leg runs, optional title), status badge, location notices, Sync now (only when points wait and no leg runs), key points log, legs, map pop-up |
| 3. Request detail, manager / HR | `views/widgets/tracking_section_manager.dart`: status, Active Hours, Start / Stop count, hours within work hours (when enabled), View full route (only with at least one leg), key points, legs. Cancelling tracking is a web back-office action, so it is not in the app |
| 4. Group map | `views/screens/live_group_map_screen.dart`: Live / Today / a picked day, up to 10 employees per page coloured by position (`TrackingPalette`), employee chips, status card with key points, pagination |
| Reports (back end §9, shown in the app) | `views/screens/tracking_reports_screen.dart`: Manager compliance, HR compliance, Tracking history, KPI tiles and a filter sheet (date, employee, department, request type, tracking status) |

Shared widgets: `tracking_route_map.dart` (routes drawn to scale; no map SDK in the app yet),
`tracking_map_view_dialog.dart`, `tracking_key_points_timeline.dart`, `tracking_session_card.dart`,
`tracking_metrics.dart`, `tracking_notice_banner.dart`, `tracking_choice_chip.dart`,
`tracking_status_badge.dart`, `add_manual_point_modal.dart`.

Navigation (the spec does not name a menu, so it follows the app): the request details "Tracking"
tab for screens 2 and 3, the Requests filter sheet for screen 1, More → Management → "Team Tracking"
(`liveGroupMap`, team leader / manager / HR / top management, same rule as Team Fingerprint) for the
group map, and its app bar opens the reports (`trackingReports`).

The request details "Tracking" tab is the 4th tab of
`approvables_details/views/widgets/custom_tabbar_view_approvable_details.dart` (employee requests
only). It shows the employee section to the request owner and the manager section to everyone else;
Start is enabled only when today is inside the request dates and the request is not cancelled. `views/screens/tracking_demo_hub_screen.dart` (route
`trackingDemoHub`) opens every screen and every employee state for design review.

When the back end is ready, replace `TrackingDummyData` with a repo and keep the models; the
reports and the group map then read the APIs listed in the spec (Start / Upload batch / Stop /
Current / Live grouped / History).
