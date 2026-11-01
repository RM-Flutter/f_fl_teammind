# tracking

Field-employee location tracking for requests such as missions. **This is UI and design work only. It has no API calls; all data comes from `data/dummy/tracking_dummy_data.dart`.**

- `data/models/`: `TrackingSessionModel` (a tracking session tied to a request), `TrackingPointModel` (GPS or manual point), `EmployeeTrackingSummaryModel`, and the `RequestTrackingStatus` / `TrackingSessionStatus` enums.
- `views/widgets/tracking_section_employee.dart` / `tracking_section_manager.dart`: the "Tracking" tab inside request details (`requests/details/views/widgets/custom_tabbar_view.widget.dart`). Employees start, stop or cancel tracking and add manual points; managers view sessions.
- `views/widgets/`: session card, status badge, filter chips, map view dialog, manual point modal and tile, cancel modal, and a home preview banner (commented out on home).
- `views/screens/live_group_map_screen.dart`: live map of several employees with time filters. `tracking_demo_hub_screen.dart`: a demo entry point (`trackingDemoHub` route) for design review.

When the backend is ready, replace `TrackingDummyData` with a repo and keep the models.
