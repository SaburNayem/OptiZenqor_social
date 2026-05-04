importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCoA3d1LEUJa9vrQpNGIeFZDrdQiJiq73s',
  appId: '1:167114516857:web:54b741736d151b9850a7a8',
  messagingSenderId: '167114516857',
  projectId: 'optizenqor-socity',
  authDomain: 'optizenqor-socity.firebaseapp.com',
  storageBucket: 'optizenqor-socity.firebasestorage.app',
  measurementId: 'G-RQM1G7G74Q',
});

firebase.messaging();
