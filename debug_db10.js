const mongoose = require('mongoose');
const DriverProfile = require('./models/DriverProfile');
const User = require('./models/User');

async function checkDrivers() {
    await mongoose.connect('mongodb+srv://goudariteshkumar1_db_user:g2iChhQXdSonfPLW@cluster0.ib5tcmx.mongodb.net/?appName=Cluster0');
    console.log("Connected to DB");

    try {
        const drivers = await DriverProfile.find().populate('user');
        console.log("Drivers:");
        for (let d of drivers) {
            console.log(`- ${d.user.name} (${d._id})`);
            console.log(`  is_verified: ${d.is_verified}`);
            console.log(`  isActive (User): ${d.user.isActive}`);
        }
    } catch (e) {
        console.error(e);
    } finally {
        await mongoose.disconnect();
    }
}
checkDrivers();
