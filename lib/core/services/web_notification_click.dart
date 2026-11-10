// Web only: opening the app from a clicked push notification.
// The service worker (web/firebase-messaging-sw.js) either posts the clicked
// notification's endpoint to an open app window, or opens the app with
// `?notification_endpoint=...`. On mobile this is a no-op (taps go through
// FirebaseMessaging.onMessageOpenedApp / getInitialMessage).
export 'web_notification_click_stub.dart'
    if (dart.library.html) 'web_notification_click_web_impl.dart';
