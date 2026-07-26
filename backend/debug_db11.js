const mongoose = require('mongoose');
const DriverProfile = require('./models/DriverProfile');
const User = require('./models/User');

async function verifyDrivers() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    console.log("Connected to DB");

    try {
        await DriverProfile.updateMany({}, { is_verified: true });
        console.log("All drivers verified.");
    } catch (e) {
        console.error(e);
    } finally {
        await mongoose.disconnect();
    }
}
verifyDrivers();
