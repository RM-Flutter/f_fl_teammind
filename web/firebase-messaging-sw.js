// Receives FCM pushes while the web app is in the background or closed.
// The SDK version must match firebase_core_web's supportedFirebaseJsSdkVersion,
// and the config must match DefaultFirebaseOptions.web (project rm-emp).
importScripts("https://www.gstatic.com/firebasejs/12.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.7.0/firebase-messaging-compat.js");

// Must match WebNotificationClick in lib/core/services/web_notification_click_web.dart.
const CLICK_MESSAGE_TYPE = "rm_notification_click";
const CLICK_QUERY_PARAM = "notification_endpoint";

// The app's `endpoint` (a route GeneralListener.linksAction understands) for a
// clicked notification. Notifications the Firebase SDK displayed keep the
// message under data.FCM_MSG; the ones shown below keep it in data.endpoint.
function endpointOf(notification) {
    const data = notification.data || {};
    if (data.endpoint) return data.endpoint;
    const fcm = data.FCM_MSG || {};
    return (fcm.data && fcm.data.endpoint) || null;
}

// Registered BEFORE firebase.messaging(): the SDK's own click handler stops
// the event for its notifications, so a listener added after it never runs.
self.addEventListener("notificationclick", (event) => {
    const fcm = (event.notification.data || {}).FCM_MSG;
    // The backend set an explicit link (webpush.fcm_options.link or
    // notification.click_action): leave it to the SDK, which opens that link.
    if (fcm && ((fcm.fcmOptions && fcm.fcmOptions.link) ||
        (fcm.notification && fcm.notification.click_action))) return;

    event.stopImmediatePropagation();
    event.notification.close();
    const endpoint = endpointOf(event.notification);

    event.waitUntil((async () => {
        const windows = await clients.matchAll({ type: "window", includeUncontrolled: true });
        const appWindow = windows.find((w) => new URL(w.url).origin === self.location.origin);
        if (appWindow) {
            // App already open: focus it and let it navigate.
            await appWindow.focus();
            if (endpoint) appWindow.postMessage({ type: CLICK_MESSAGE_TYPE, endpoint });
            return;
        }
        // App closed: open it; the splash reads the endpoint from the URL.
        const url = endpoint
            ? "/?" + CLICK_QUERY_PARAM + "=" + encodeURIComponent(endpoint)
            : "/";
        await clients.openWindow(url);
    })());
});

firebase.initializeApp({
    apiKey: 'AIzaSyCsC9qZ146cR_TYGdvWNt_3pyw6W7eRet4',
    appId: '1:288740335268:web:b6d7cf1016a86818f8d031',
    messagingSenderId: '288740335268',
    projectId: 'rm-emp',
    authDomain: 'rm-emp.firebaseapp.com',
    storageBucket: 'rm-emp.firebasestorage.app',
});

const messaging = firebase.messaging();

// Messages with a `notification` payload are shown by the browser
// automatically. Data-only messages (title/body inside `data`) are not, so
// show them here; otherwise they arrive and the user sees nothing.
messaging.onBackgroundMessage((m) => {
    if (m.notification) return;
    const data = m.data || {};
    const title = data.title;
    const body = data.body;
    if (!title || !body || title === "No Title" || body === "No Body") return;
    return self.registration.showNotification(title, {
        body,
        icon: "/icons/Icon-192.png",
        data: { endpoint: data.endpoint || null },
    });
});
