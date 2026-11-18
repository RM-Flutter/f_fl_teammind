# tracking

Location tracking linked to a request (field missions, client visits, ...). The request type on
the server decides whether tracking is `inactive`, `optional` or `required`. The API is
`{{base}}/api/emp_requests/v1/tracking` (doc: "توثيق APIs تتبع الموقع لمطوّر Flutter"); the analysis
against the dev server is in [API_INTEGRATION.md](API_INTEGRATION.md).

The app never decides on its own whether tracking may start: it shows Start when the server says
`tracking.can_start`, and otherwise the server's `can_start_reason`.

## Data
- `data/repos/tracking_repo.dart`: `TrackingRepo` (`DioHelper`). `getRequestTracking`
  (`GET requests/{id}`), `startSession` / `stopSession` (no body; pressing twice is safe),
  `getPath` (`GET requests/{id}/path`), `getLive` and `getHistory` (`mode=today|date`,
  `employee_ids[]`, `department_ids[]`, `only_tracking`). Success is `status == true` (a boolean).
  Uploading points is not here; it lives in `core/services/location_tracking` because it also runs
  with no screen.
- `data/models/`:
  - `request_tracking.model.dart`: `RequestTrackingInfoModel` (the `tracking` block that also comes
    with every request list item and the approvable details) and `RequestTrackingDetailsModel`
    (`GET requests/{id}`).
  - `tracking_session.model.dart`: one session (every Start / Stop is a new one). `points` holds the
    key points (`main_points`) or the whole `path`, attached by `session_id`.
  - `tracking_point.model.dart`: a `main_points` item (`kind`) or a `path` item (`type`).
  - `employee_tracking_summary.model.dart`: one employee on the group map (live item, merged with
    the history item in "Today"), and `TrackingEmployeesPage`.
  - `tracking_status.enum.dart`: session status, location state and live presence enums; it
    re-exports `RequestTrackingStatus` from `core/models/request_tracking_status.dart`.
- Server times are UTC; the models keep them in local time.

## Controllers
- `controllers/request_tracking_controller.dart`: the request's Tracking tab. Start (asks for the
  location permission first), Stop (sends the queue before and after), key point, Sync now,
  loading the full path. Reloads `GET requests/{id}` after each action, and keeps the phone's
  recorder in step with the server's `active_session_id`.
- `controllers/group_tracking_map_controller.dart`: the group map. Live refreshes every 60 s;
  Today merges `live` and `history?mode=today` (same page, filters, order and `color_index`).

## Screens and widgets
| API doc screen | Where |
|---|---|
| 1. Requests list | Filter in `requests/main_request_layout/views/widgets/search_filter_widget.dart` (any / with / without / required missing), sent as `tracking=` by `RequestsViewModel`; badge on `core/widgets/approvable_card_widget.dart` |
| 2. Request details, employee | `views/widgets/tracking_section_employee.dart` |
| 3. Request details, manager / HR | `views/widgets/tracking_section_manager.dart`, plus `TrackingApprovalWarning` above the approve actions (`approvables_details` bottom bar) |
| 4. Group map | `views/screens/live_group_map_screen.dart` (More → "Team Tracking", route `liveGroupMap`) |

`views/widgets/request_tracking_tab.dart` is the tab in `approvables_details`: it shows only for
`employee_requests` whose `tracking.requirement` is not `inactive`, gives the owner the employee
section and everyone else the manager section, and has `openTrackingRouteMap` (full route pop-up).

Shared widgets: `tracking_route_map.dart` (`TrackingRouteMap`: Google Maps through
`tracking_google_route_map.dart` when `AppConstants.googleMapsEnabled`, otherwise routes drawn to
scale with no map tiles), `tracking_map_view_dialog.dart`, `tracking_key_points_timeline.dart`,
`tracking_session_card.dart`, `tracking_metrics.dart`, `tracking_notice_banner.dart`,
`tracking_choice_chip.dart`, `tracking_status_badge.dart`, `add_manual_point_modal.dart`.

## Recording on the phone
`LocationTrackingService` (core) records a point a minute while a session is open, keeps the
queue across restarts and uploads it with the API rules; see `core/services/README.md`.
- Android: geolocator's foreground service (ongoing notification) with "While using" permission;
  `FOREGROUND_SERVICE_LOCATION` is in the manifest.
- iOS: `location` background mode; the app asks for "Always". With "While using" only, the
  employee sees "Permission Limited".
- Web: no background location, so Start / Stop / key point / Sync are hidden; the data, the map
  and the group map work.

## Google Maps
Off until the keys are set (`AppConstants.googleMapsEnabled`, or
`--dart-define=GOOGLE_MAPS_ENABLED=true`). Keys: Android `MAPS_API_KEY=...` in
`android/local.properties` (or the `MAPS_API_KEY` env var on CI), iOS `MAPS_API_KEY = ...` in
`ios/Flutter/Maps.xcconfig` (git-ignored), web the script tag in `web/index.html`.

## Not in the app yet
The tracking reports (`reports/manager-compliance`, `hr-compliance`, `history`) and
`GET current/{profileId}` exist on the server but are not documented yet. The old dummy-data
reports screen was removed; add the reports once the back end documents them (ideally through the
app's reports catalog in `features/reports`).
