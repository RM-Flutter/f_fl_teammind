# shifts

Shift change requests and the shift schedule.

- `controllers/shift_change_controller.dart`: `ShiftChangeController` (app-wide provider). `fetchRequests` (personal or incoming, with filters), `fetchSchedulerCalendar` (shift definitions and assignments, used to pick the target shift), and `submitShiftChangeRequest`.
- `services/shift_change_requests_service.dart`: `emp_requests/v1/shift-change-requests` (create and calendar data) and `approval-system/v1/shift_change_requests` (lists).
- `models/shift_change_request_model.dart`: `ShiftDefinitionModel`, `ShiftAssignmentModel`, `SchedulerEmployeeModel`, `ShiftChangeRequestModel`.
- `views/shift_change_requests_screen.dart`: list. Details open `approvableDetails` with type `shift_change_requests`.
- `views/add_shift_change_request_screen.dart`: pick a date and the new shift from the scheduler calendar.
- `views/shifts_scheduler_webview_screen.dart`: opens the backend's web shift scheduler in a WebView, with the auth token in the URL.

Postman collection: `docs/postman/shift-change-requests.postman_collection.json` in the backend repo.
