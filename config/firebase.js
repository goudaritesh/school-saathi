const admin = require("firebase-admin");
const fs = require('fs');
const path = require('path');

try {
    const keyPath = path.join(__dirname, "firebase-service-account.json");
    if (fs.existsSync(keyPath)) {
        const serviceAccount = require(keyPath);
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log("Firebase Admin initialized successfully.");
    } else {
        console.warn("⚠️ Firebase firebase-service-account.json not found! Push notifications will be disabled.");
    }
} catch (error) {
    console.error("⚠️ Failed to initialize Firebase Admin:", error.message);
}

module.exports = admin;
