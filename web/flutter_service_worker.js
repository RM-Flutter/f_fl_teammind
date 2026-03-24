'use strict';
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

firebase.initializeApp({
 apiKey: 'AIzaSyA7t-KoyfGWh2JAv1fkqb9WUW1gxabWves',
    appId: '1:288740335268:web:d9b72d1e151ea512f8d031',
    messagingSenderId: '288740335268',
    projectId: 'rm-emp',
    authDomain: 'rm-emp.firebaseapp.com',
    storageBucket: 'rm-emp.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log('Received background message: ', message);
});
