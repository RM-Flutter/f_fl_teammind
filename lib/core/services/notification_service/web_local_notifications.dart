// Web only: attendance reminders shown by the browser while the app is open in a tab.
// Browsers cannot schedule a notification for a closed tab, so the reminders are timers
// in the page; a reload or a new tab schedules them again (CheckInScheduler).
// On mobile this is a no-op (flutter_local_notifications schedules them).
export 'web_local_notifications_stub.dart'
    if (dart.library.html) 'web_local_notifications_web_impl.dart';
