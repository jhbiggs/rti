importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyD3_Q9--91UHWbrmbHVshMTfV5X2YjToWU",
  authDomain: "rti4-db375.firebaseapp.com",
  databaseURL: "https://rti4-db375-default-rtdb.firebaseio.com",
  projectId: "rti4-db375",
  storageBucket: "rti4-db375.appspot.com",
  messagingSenderId: "972193772481",
  appId: "1:972193772481:web:4967ed6c15bf5d9a663540",
  measurementId: "G-Z6WVEYEL0T"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});