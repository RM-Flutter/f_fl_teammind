# lib/core/services/notification_service

On-device notifications. The FCM push handling sits one level up, in `../notification_service.dart`.

| File | What it does / how |
|---|---|
| `local_notification_service.dart` | `LocalNotificationService.init()`, called in `main()`. Initialises `flutter_local_notifications` and timezone data. Also `scheduleNotification`, `canScheduleExact`, `cancelAllPending` (scheduled only, keeps shown ones). |
| `check_in_scheduler.dart` | `CheckInScheduler.scheduleNotifications(context)` (called from `HomeController.getHome`) schedules on-device reminders for the next 14 days. Fixed hours: check-in 5 min before `working_hours_from`, check-out at `working_hours_to`. Free hours: check-in at `working_hours_from_start` only. Shifts: each shift in the own profile's `this_week_shifts` (`/emp_requests/v1/employees/{employee_profile_id}`). Skips the backend's `/emp_requests/v1/off-days-this-month` (`off_days[].date`), plus `weekend` / `specific_dates` / `recurring_rules` / `holidays` from `US2` and approved day-leaves from `approval-system/v1/employee_requests/employee/my-approvables?status=approved` (these also cover days after month end). Plus the next work anniversary from `hire_date` (US1). Runs only when `allowed_fingerprint_types` (fallback `av_fingerprint`) has an enabled type; calls the APIs at most every 3 hours unless US1/US2 change; falls back to inexact alarms when Android denies exact ones. |
| `notification_service.dart` | Older notification helper. The active FCM service is `../notification_service.dart`. |
| `timeout_message_service.dart` | `TimeoutMessage.show/hide`: a dialog that closes itself after a timeout, with an optional `beforeClose` hook |
