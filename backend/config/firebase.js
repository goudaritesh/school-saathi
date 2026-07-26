const admin = require("firebase-admin");
const fs = require('fs');
const path = require('path');

try {
    const renderSecretPath = '/etc/secrets/firebase-adminsdk.json';
    const localKeyPath = path.join(__dirname, "firebase-service-account.json");
    
    let keyPath = null;
    if (fs.existsSync(renderSecretPath)) {
        keyPath = renderSecretPath;
    } else if (fs.existsSync(localKeyPath)) {
        keyPath = localKeyPath;
    }

    if (keyPath) {
        // Method 1: Initialize using the JSON file
        const serviceAccount = require(keyPath);
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log("Firebase Admin initialized successfully using JSON file.");
    } else if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_PRIVATE_KEY && process.env.FIREBASE_CLIENT_EMAIL) {
        // Method 2: Initialize using Environment Variables (EASIER FOR RENDER)
        admin.initializeApp({
            credential: admin.credential.cert({
                projectId: process.env.FIREBASE_PROJECT_ID,
                clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                // Replace escaped literal \n with actual newline characters
                privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
            })
        });
        console.log("Firebase Admin initialized successfully using Environment Variables.");
    } else {
        console.warn("⚠️ Firebase credentials not found (File or Env Vars)! Push notifications will be disabled.");
    }
} catch (error) {
    console.error("⚠️ Failed to initialize Firebase Admin:", error.message);
}

module.exports = admin;
