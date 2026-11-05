// Receives FCM pushes while the web app is in the background or closed.
// The SDK version must match firebase_core_web's supportedFirebaseJsSdkVersion,
// and the config must match DefaultFirebaseOptions.web (project rm-emp).
importScripts("https://www.gstatic.com/firebasejs/12.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyCsC9qZ146cR_TYGdvWNt_3pyw6W7eRet4',
    appId: '1:288740335268:web:b6d7cf1016a86818f8d031',
    messagingSenderId: '288740335268',
    projectId: 'rm-emp',
    authDomain: 'rm-emp.firebaseapp.com',
    storageBucket: 'rm-emp.firebasestorage.app',
});

// Necessary to receive background messages. Messages with a `notification`
// payload are shown by the browser automatically.
const messaging = firebase.messaging();

messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m);
});
