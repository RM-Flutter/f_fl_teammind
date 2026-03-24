importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: 'AIzaSyA7t-KoyfGWh2JAv1fkqb9WUW1gxabWves',
    appId: '1:288740335268:web:d9b72d1e151ea512f8d031',
    messagingSenderId: '288740335268',
    projectId: 'rm-emp',
    authDomain: 'rm-emp.firebaseapp.com',
    storageBucket: 'rm-emp.firebasestorage.app',
});

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((payload) => {
    console.log("onBackgroundMessage", payload);
    
    // Get notification data
    const notificationTitle = payload.notification?.title || payload.data?.title || 'Notification';
    const notificationOptions = {
        body: payload.notification?.body || payload.data?.body || '',
        // Use app icon from web/icons (you can replace Icon-192.png with your app logo)
        // Make sure to copy your app logo to web/icons/notification-icon.png if you want to use it
        icon: '/icons/Icon-192.png', // Use app icon instead of Chrome logo
        badge: '/icons/Icon-192.png',
        image: payload.notification?.image || payload.data?.image || '/icons/Icon-192.png',
        tag: 'notification',
        requireInteraction: false,
        silent: false,
        data: payload.data || {}
    };
    
    // Show notification with app icon
    return self.registration.showNotification(notificationTitle, notificationOptions);
});

