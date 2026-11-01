# lib/core/services/notification_service

On-device notifications. The FCM push handling sits one level up, in `../notification_service.dart`.

| File | What it does / how |
|---|---|
| `local_notification_service.dart` | `LocalNotificationService.init()`, called in `main()`. Initialises `flutter_local_notifications` and timezone data. |
| `check_in_scheduler.dart` | `CheckInScheduler` schedules check-in and check-out reminder notifications from the user's working hours and shifts in the `US2` settings (`UserSettings2Model`). The Workmanager background job in `main.dart` that refreshes them is commented out right now. |
| `notification_service.dart` | Older notification helper. The active FCM service is `../notification_service.dart`. |
| `timeout_message_service.dart` | `TimeoutMessage.show/hide`: a dialog that closes itself after a timeout, with an optional `beforeClose` hook |
